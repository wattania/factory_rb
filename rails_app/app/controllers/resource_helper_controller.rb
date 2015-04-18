#encoding: UTF-8

class ResourceHelperController < ApplicationController
  def __find_with_lock_version model, id, lock_version
    raise "no lock_version " if lock_version.blank?
    n = model.where(id: id).where(lock_version: lock_version).first
    if n.blank?  
      raise load_message(:lock_version_err)
    end
    n
  end

  def index_column_config result
    result[:columns] = []

    name = controller_name
    name = params[:program] unless params[:program].blank?

    SysColumnControl.where(user_id: session[:user_id])
      .where(program_name: name)
      .limit(1).each{|row|
        result[:columns] = JSON.parse row.columns
      }
  end

  def create_reset_columns result

    name = controller_name
    name = params[:program] unless params[:program].blank?

    SysColumnControl.where(user_id: session[:user_id])
      .where(program_name: name)
      .delete_all
  end

  def create_column_event result
    name = controller_name
    name = params[:program] unless params[:program].blank?

    SysColumnControl.set_column_config(session[:user_id], name, params[:column]){|columns, cols|
      case params[:event]
      when 'columnmove'
        (params[:orders] || []).each{|col_data|
          exist_cols = columns.select{|e| e["property"] == col_data['didx']}
          if exist_cols.first.nil?
            columns.push({"property" => col_data['didx'], "idx" => col_data['idx']})
          else
            exist_cols.each{|ee| ee["idx"] = col_data['idx']}
          end
        }

      when 'columnshow '
        if cols.size > 0
          cols.each{|e| e["hide"] = false}
        else
          columns.push({"property" => params[:column], "hide" => false})
        end

      when 'columnhide'  
        if cols.size > 0
          cols.each{|e| e["hide"] = true}
        else
          columns.push({"property" => params[:column], "hide" => true})
        end

      when 'sortchange'
        if cols.size > 0
          cols.each{|e| e["direction"] = params[:direction]}
          columns.each{|e|
            e["direction"] = nil unless e["property"] == params[:column]
          }
        else
          columns.push({"property" => params[:column], "direction" => params[:direction]})
        end

      when 'columnresize'
        if cols.size > 0
          cols.each{|e| e["width"] = params[:width]}
        else
          columns.push({"property" => params[:column], "width" => params[:width]})
        end
      end
    }
  end

  def project_stmt a_project_hash, a_other_array = []
    XModelUtils.project_stmt a_project_hash, a_other_array
  end

  def result_total stmt
    total = 0

    stmt.engine.find_by_sql(<<-TOTAL
      SELECT COUNT(*) AS total_rows FROM ( #{stmt.to_sql} ) tt
TOTAL
      ).each{|row|
      total = row.total_rows
    }
=begin
    unless stmt.join_sql.blank?
      if stmt.where_sql.blank?
        total = stmt.engine.where('1 = 1').joins(stmt.join_sql).size
      else
        total = stmt.engine.where(stmt.where_sql.sub 'WHERE', '').joins(stmt.join_sql).size
      end
    else
      unless stmt.where_sql.blank?
        total = stmt.engine.where(stmt.where_sql.sub 'WHERE', '').size
      else
        total = stmt.engine.where("1 = 1").size
      end
    end
=end
    total
  end


  def get_page_no a_stmt, id, a_orders = {}, field_name = [:id, :id]
    ret = 1
    page_size = params[:page_size].to_s.to_i
    return ret if page_size <= 0
    return ret if id.blank?

    stmt = nil
    if block_given?
      stmt = result_rows_order_stmt a_stmt.clone, a_orders, &Proc.new
    else
      stmt = result_rows_order_stmt a_stmt.clone, a_orders
    end

    stmt_order_by = " ORDER BY " + stmt.engine.arel_table.order(stmt.orders.clone).to_sql.split("ORDER BY").last.to_s
 
    page_no_stmt = Arel.sql "(row_number() OVER ( #{stmt_order_by} ) / #{page_size}) + 1 AS page_no"

    me = stmt.engine.arel_table
    stmt.project([page_no_stmt, me[field_name.first]])
    stmt.engine.find_by_sql("SELECT page_no FROM ( #{stmt.to_sql} ) page WHERE page.#{field_name.last} = #{id}").each{|row| ret = row.page_no }
    ret
  end

  def result_rows_order_stmt stmt, a_orders = {}
    orders = stmt.orders.clone

    unless params[:sort].blank?
      sorts = JSON.parse(params[:sort])
      sorts.each{|sort|
        property = sort["property"]
        direction = sort["direction"].to_s.downcase

        if !property.blank? and ['asc', 'desc'].include? direction
          if a_orders.keys.include? property
            field = a_orders[property]
            if block_given?
              res = yield property
              field = res if res
            end
            orders.unshift field.method(direction).call  
          end
        end
      }
      unless orders.blank?
        stmt.orders.clear
        stmt.order orders
      end
    end
    stmt
  end

  def result_rows a_stmt, a_orders = {}
    stmt = a_stmt.clone
    if block_given?
      result_rows_order_stmt stmt, a_orders, &Proc.new
    else
      result_rows_order_stmt stmt, a_orders
    end
  
    unless params[:limit].blank?
      limit = params[:limit].to_s.to_i
      stmt.take(limit >= 0 ? limit : 0)
    end

    unless params[:start].blank?
      start = params[:start].to_s.to_i
      stmt.skip(start >= 0 ? start : 0)
    end
    stmt.engine.find_by_sql stmt
  end

  def __format_backtrace backtrace
    XEodUtils.mini_backtrace backtrace 
=begin
    ret = []
    _mark = false
    backtrace.each{|m|
      ret << m
      _mark = true if m.start_with? Rails.root.to_s
      if _mark
        break unless m.start_with? Rails.root.to_s
      end
    }
    ret
=end
     
  end

  def index_init_filter result
  end

  def __method_operation name, result
     
    @__rest_operation = name.to_sym
    begin
      
      func = name + "_" + params[:method].to_s
       
      case name
      when 'create'
        if func.split('_')[1] == 'init'
          result[:passed] = true
        end
      end
        
      ActiveRecord::Base.transaction do
        self.method(func).call result
      end
    rescue ActiveRecord::Rollback => rollback
      puts "--- rollback ----!!"
    rescue ActiveRecord::StaleObjectError => lock_error
      record_details = ""
      begin
        unless lock_error.record.blank?
          table_name = lock_error.record.class.table_name
          record_id  = lock_error.record.id
          record_details = "<br>( lock_version = #{lock_error.record.lock_version}, " + table_name.to_s + ", " + record_id.to_s + ")</br>"
        end  
      rescue Exception => eeee
        
      end
      
      result = {
        lock_error: true,
        success: false, 
        message: "รายการนี้ถูกแก้ไขโดยบุคคลอื่นแล้ว ไม่สามารถดำเนินการต่อได้",
        rows: [], 
        total: 0, 
        #backtrace: [lock_error.attempted_action, record_details]
      }
    rescue Exception => e
      puts e.message
      puts e.backtrace
      result = result.merge({success: false, message: e.message, rows: [], total: 0, backtrace: __format_backtrace(e.backtrace)})
    end
 
    result
  end

  def index
    result = {success: true, message: "", rows: [], total: 0, backtrace: []}
    return if result[:send_file]
    render json: __method_operation(__callee__.to_s, result)
  end

  def update
    result = {success: true, message: "", rows: [], backtrace: []}
    render json: __method_operation(__callee__.to_s, result)
  end

  def create 
    result = {success: true, message: "", rows: [], backtrace: []}
    res = __method_operation(__callee__.to_s, result)
    return if result[:send_file]
    render json: res
  end

  def show
    result = {success: true, message: "", rows: [], backtrace: []}
    res = __method_operation(__callee__.to_s, result)
    return if result[:send_file]
    render json: res
  end

  def destroy
    result = {success: true, message: "", rows: [], backtrace: []}
    render json: __method_operation(__callee__.to_s, result)
  end

  protected
  def destroy_with_lock_version result, n
    raise "Can not delete without lock_version!" if params[:lock_version].blank?
    
    unless n.lock_version.to_s == params[:lock_version].to_s
      result[:success] = false
      result[:message] = 'รายการที่จะลบมีการเปลี่ยนแปลงโดยบุคคล หรือ โปรแกรมอื่นแล้ว</br> ไม่สามารถทำการลบได้ </br> ให้ Reload Grid ใหม่'
    else
      #stamp_meta_data n, @__rest_operation
      n.delete_flag = true 
      yield result, n if block_given?
      save_record result, n
      #result[:valid]  = n.valid?
      #result[:errors] = n.errors
      #n.save! if result[:valid]
    end

  end

  def delete_record_with_lock1 n, lock_version, result, has_many = []
    raise "Can not delete without lock_version!" if lock_version.blank?

    unless n.lock_version == lock_version
      result[:success] = false
      result[:message] = 'รายการที่จะลบมีการเปลี่ยนแปลง</br> ไม่สามารถทำการลบได้ </br>แนะนำให้ Reload ใหม่'
    else
      #stamp_meta_data n, @__rest_operation
      n.delete_flag = true 
      result[:valid]  = n.valid?
      result[:errors] = n.errors
      n.save! if result[:valid]
    end
  end

  def delete_record result, n
    #stamp_meta_data n, @__rest_operation

    n.delete_flag = true 

    n.class.name.constantize.reflect_on_all_associations.each{|aa|
      case aa.macro
      when :has_many
        n.method(aa.name).call.each{|associate|
          if associate.has_attribute? :delete_flag
            associate.delete_flag = true
            associate.save!
          end
        }
      end
    }

    result[:valid] = n.valid?
    result[:errors] = n.errors
    n.save! if result[:valid]
  end

  def validate_record n, result
    result[:errors] = {} if result[:errors].nil?
    result[:valid]  = n.valid?

    n.errors.messages.each{|k, v|
      process = false
      n.class.name.constantize.reflect_on_all_associations.each{|aa|
        if aa.name.to_s == k.to_s
          case aa.macro
          when :has_many
            n.method(aa.name).call.each{|associate|
              associate.errors.messages.each{|field, err_msgs|
                result[:errors][field] = [] if result[:errors][field].nil?
                result[:errors][field] += err_msgs
                process = true
              }
            }
          end
        end
      }

      unless process
        result[:errors][k] = [] if result[:errors][k].nil?
        result[:errors][k] += v
      end 
    }
  end

  def save_record result, n
    #stamp_meta_data n, @__rest_operation
    validate_record n, result
    n.save! if result[:valid]
  end

  def save_record_with_associate result, n, name_list = [], u_mode = :update
    if @__rest_operation == :update and u_mode != :update
      #stamp_meta_data n, u_mode 
    else
      #stamp_meta_data n, @__rest_operation
    end
    validate_record n, result 
    is_valid = result[:valid]

    xx = []
    name_list.each{|_name| xx.push _name.to_s}
     
    if result[:valid]
      n.class.name.constantize.reflect_on_all_associations.each{|aa|
        if xx.include? aa.name.to_s
          case aa.macro
          when :has_many  
            n.method(aa.name).call.each{|associate|
              if associate.changed?
                valid = associate.valid?
                result[:valid] = false unless valid
                if result[:valid]
                  associate.save
                else 
                  associate.errors.messages.each{|field, err_msgs|
                    result[:errors][field] = [] if result[:errors][field].nil?
                    result[:errors][field] += err_msgs
                  }
                end
              end

              if associate.new_record?
                #stamp_meta_data associate, :create 
                
              else
                if associate.changed?
                  if u_mode.blank?
                    #stamp_meta_data associate, :update 
                  else
                    #stamp_meta_data associate, u_mode
                  end
                  associate.save if result[:valid]
                end
              end
            }

=begin
              if associate.changed?  
                puts "--- changed ---"
                p associate.changes
                stamp_meta_data associate, :update  
                result[:valid] = associate.valid?
                 
                unless result[:valid]
                  associate.errors.messages.each{|field, err_msgs|
                    result[:errors][field] = [] if result[:errors][field].nil?
                    result[:errors][field] += err_msgs
                  }
                else
                  puts "save1"
                  associate.save
                end
              end 

              unless associate.new_record?   
                puts "-- no new record ---"
                if associate.changed?  
                  stamp_meta_data associate, :update 
                  if result[:valid]
                    puts "save2"
                    associate.save  
                  end
                end
              else  
                puts "-- new record - stamp_meta_data ---"
                stamp_meta_data associate, :create   
              end
=end

          end
        end 
      }
    end  

    if result[:valid]
      n.save!
    else
      raise ActiveRecord::Rollback
    end

  end 
end
