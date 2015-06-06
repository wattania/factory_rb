# To change this template, choose Tools | Templates
# and open the template in the editor.

class XModelUtils
  def self.__filter_field k, v, projects  
    if projects[k].is_a? Hash

      field   = projects[k][:field]
      filter  = projects[k][:filter]

      if !field.blank? and !filter.blank?
        case filter
        when :like
          ret_stmt = field.matches v 
        when :gt 
          ret_stmt = field.gt v
        when :gteq
          ret_stmt = field.gteq v
        when :lt 
          ret_stmt = field.lt v
        when :lteq
          ret_stmt = field.lteq v
        end  
      end
    end

  end

  def self.filter_stmt stmt, afilter, projects = {}
    if afilter.is_a? Hash
      afilter.each{|k, v|
        next if v.blank?
        if v.is_a? Array
          _stmt = nil
          v.each{|_v|
            unless _v.blank?
              ret_stmt = nil
              ret_stmt = yield k, _v if block_given?
              ret_stmt = __filter_field k, _v, projects if ret_stmt.blank?

              unless ret_stmt.blank?
                if _stmt.blank?
                  _stmt = ret_stmt.clone 
                else
                  _stmt = _stmt.clone.or(ret_stmt)
                end
              end
              
            end
          }
          
          stmt.where(_stmt.clone) unless _stmt.blank?
           
        else
          ret_stmt = nil
          ret_stmt = yield k, v if block_given?
          ret_stmt = __filter_field k, v, projects if ret_stmt.blank?
          stmt.where(ret_stmt.clone) unless ret_stmt.blank?

        end
      }
    end

    stmt
  end

  def self.fn_param type, value, null_when_blank = true
    case type
    when :date
      return 'NULL' if value.nil?
      return "'#{value.to_date}'"

    when :bool, :boolean
      value ? 'true' : 'false'

    else    
      if value.blank?  
        return 'NULL' if null_when_blank
      else  
        return "'#{value}'"
      end
    end
  end

  def self.project_stmt a_project_hash, a_other_array = []
    ret = []
    a_project_hash.each{|_k, _v| 
      k = _k
      v = _v
      if _v.is_a? Hash 
        v = _v[:field]
      end
      ret << v.clone.method('as').call(k) 
    }
    
    ret + a_other_array
  end

  def self.currency a_field, opts = {}#,a_scale = 0, a_precision = 20, zero_blank = false
    
    a_precision = opts[:precision] || 20
    scale = (opts[:scale] || 0)

    precision = "0"
    (1..a_precision).each_with_index{|pp, index|
      precision = "," + precision if precision.gsub(',', '').size % 3 == 0
      precision = "9" + precision
    }

    
    if scale > 0
      precision += "D"
      (1..scale).each{|ss| precision += "9" }
    end

    if opts[:format]#5172
      precision = opts[:format]
    end

    if opts[:zero_blank]

      field_name = "\"#{a_field.relation.name}\".\"#{a_field.name}\""

      Arel.sql(<<-ZERO_BLANK
        CASE WHEN COALESCE(#{field_name}, 0) != 0
        THEN
          TRIM( TO_CHAR( COALESCE( #{field_name}, 0 ), '#{precision}' ) )
        ELSE
          ''
        END
        ZERO_BLANK
        )
    else
      Arel::Nodes::NamedFunction.new('trim', [ 
        Arel::Nodes::NamedFunction.new('to_char', [ 
          Arel::Nodes::NamedFunction.new('COALESCE', [a_field, 0]), Arel::Nodes::Quoted.new(precision)
        ])
      ])  
    end

  end

  def self.desc name_field, desc_field, sign = " - ", suffix_desc = nil
    empty = [ sign ]
    desc_lst = [ Arel::Nodes::Quoted.new(sign), desc_field]
    unless suffix_desc.nil?
      empty.push suffix_desc 
      desc_lst.push suffix_desc
    end
    desc = Arel::Nodes::NamedFunction.new("NULLIF", [ Arel::Nodes::NamedFunction.new("CONCAT", desc_lst),  Arel::Nodes::Quoted.new( empty.join('') )])
 
    Arel::Nodes::NamedFunction.new("CONCAT", [
      name_field,
      Arel::Nodes::NamedFunction.new("COALESCE", [ desc ])
    ])
  end

  def self.timestamp field 
    Arel::Nodes::NamedFunction.new('to_char', [field, Arel::Nodes::Quoted.new('DD/MM/YYYY HH24:MI:SS')]) 
  end

  def self.date field 
    Arel::Nodes::NamedFunction.new('to_char', [field, Arel::Nodes::Quoted.new('DD/MM/YYYY')]) 
  end

  def self.join_rf stmt, rf, field, key_type_sym
    stmt.join(rf, Arel::Nodes::OuterJoin).on(
      rf[:delete_flag].eq(false).and(
        rf[:code].eq(field).and(
          rf[:key_type].eq(TbReference::KEY_TYPE[key_type_sym])
          )
        )
      )
    stmt
  end

  def self.join_st stmt, rf, mm, flow_name
    stmt.join(rf, Arel::Nodes::OuterJoin).on(
      rf[:delete_flag].eq(false).and(
        rf[:status_no].eq(mm[:status_no]).and(
          rf[:flow_name].eq(flow_name)
          )
        )
    )
    stmt
  end

  def self.stamp_time mode, program_name, data =  {}
#    user_id = session[:user_id]
    user_id = "SYSTEM"
    date_time = DateTime.now # "now()"
    stamp_obj = {
      "edit_program" => program_name,
      "log_action" => mode,
#      "ip_address" => get_ip()
    }

    if (mode == :create)
      stamp_obj["create_user"] = user_id
      stamp_obj["create_date_time"] = date_time

      stamp_obj["edit_user"] = user_id
      stamp_obj["edit_date_time"] = date_time
    elsif (mode == :update || mode == :submit || mode == :cancel)
      stamp_obj["edit_user"] = user_id
      stamp_obj["edit_date_time"] = date_time
    elsif (mode == :verify || mode == :approve || mode == :revise || mode == :reject || mode == :settle)
      stamp_obj["verify_user"] = user_id
      stamp_obj["verify_date_time"] = date_time
    elsif (mode == :delete)
      stamp_obj["edit_user"] = user_id
      stamp_obj["edit_date_time"] = date_time
      stamp_obj["delete_flag"] = true
    end
    data.merge(stamp_obj)
  end
end
