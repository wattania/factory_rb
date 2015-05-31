class Programs::QuotationController < ResourceHelperController
  def item_group_stmt field
    it = TbQuotationItem.arel_table
    qa = TbQuotation.arel_table
    stmt = it.project(field).where(it[:quotation_uuid].eq qa[:uuid]).order(field)
    stmt.distinct
    
    yield stmt if block_given?

    stmt = Arel::Nodes::NamedFunction.new("ARRAY", [Arel.sql(stmt.to_sql)])
  end

  def item_total_stmt field 
    it = TbQuotationItem.arel_table
    qa = TbQuotation.arel_table
    it.project(Arel::Nodes::NamedFunction.new("SUM", [field])).where(it[:quotation_uuid].eq qa[:uuid])
  end

  def index_list result
    qa = TbQuotation.arel_table
    ct = RefCustomer.arel_table
    ur = User.arel_table
    ft = RefFreightTerm.arel_table
    it = TbQuotationItem.arel_table
    ut = RefUnitPrice.arel_table
    pt = RefPartName.arel_table
    md = RefModel.arel_table

    projects = {
      "record_id"     => qa[:id],
      "uuid"          => qa[:uuid],
      "quotation_no"  => {field: qa[:quotation_no], filter: :like },
      "customer"      => {field: ct[:display_name], filter: :like },
      "created_by"    => { field: XModelUtils.desc(ur[:first_name], ur[:last_name], ' '), filter: :like },
      "issue_date"    => qa[:issue_date],
      "freight_term"  => { field: ft[:display_name], filter: :like },
      "exchange_rate" => qa[:exchange_rate],
      "item_code"     => { field: it[:item_code], filter: :like },
      "sub_code"      => { field: it[:sub_code], filter: :like },
      "part_price"    => it[:part_price],
      "po_reference"  => { field: it[:po_reference], filter: :like },
      "remark"        => { field: it[:remark], filter: :like },
      "package_price" => it[:package_price],
      "total_price"   => Arel.sql("(COALESCE(#{it.table_name}.part_price, 0) + COALESCE(#{it.table_name}.package_price, 0)) "),
      "customer_code" => { field: it[:customer_code], filter: :like },
      "unit_price"    => { field: ut[:display_name], filter: :like },
      "part_name"     => { field: pt[:display_name], filter: :like },
      "model"         => { field: md[:display_name], filter: :like },
      "total_approve_file"    => Arel.sql("(SELECT COUNT(*) FROM #{TbQuotationApproveFile.table_name} WHERE tb_quotation_uuid = #{TbQuotation.table_name}.uuid)"),
      "total_calculate_file"  => Arel.sql("(SELECT COUNT(*) FROM #{TbQuotationCalculationFile.table_name} WHERE tb_quotation_uuid = #{TbQuotation.table_name}.uuid)"),
    }

    stmt = qa.project(project_stmt projects)
      .join(ur).on(ur[:uuid].eq(qa[:created_by]))
      .join(it, Arel::Nodes::OuterJoin).on(it[:quotation_uuid].eq(qa[:uuid]))
      .order(qa[:quotation_no])


    RefCustomer.left_join_me stmt, ct, qa
    RefFreightTerm.left_join_me stmt, ft, qa

    RefPartName.left_join_me stmt, pt, it
    RefModel.left_join_me stmt, md, it
    RefUnitPrice.left_join_me stmt, ut, it

    filter = params[:filter]
    unless filter.blank?
      filter_stmt stmt, JSON.parse(filter), projects do |k, v|
        case k
        when 'issue_date_from'
          qa[:issue_date].gteq v 
        when 'issue_date_to'
          qa[:issue_date].lteq v 
        end
      end
    end

    

    if params[:group_quotation].to_s == "true"
      ## unit price
      all_unit_price_stmt = item_group_stmt(ut[:display_name]){|st| RefUnitPrice.left_join_me st, ut, it }
      all_item_code = item_group_stmt(it[:item_code])
      all_sub_code  = item_group_stmt(it[:sub_code])
      all_cust_code = item_group_stmt(it[:customer_code])
      all_model     = item_group_stmt(md[:display_name]){|st| RefModel.left_join_me st, md, it }
      all_part_name = item_group_stmt(pt[:display_name]){|st| RefPartName.left_join_me st, pt, it }

      projects = {
        "record_id"     => qa[:id],
        "uuid"          => qa[:uuid],
        "quotation_no"  => {field: qa[:quotation_no], filter: :like },
        "customer"      => {field: ct[:display_name], filter: :like },
        "created_by"    => { field: XModelUtils.desc(ur[:first_name], ur[:last_name], ' '), filter: :like },
        "issue_date"    => qa[:issue_date],
        "freight_term"  => ft[:display_name],
        "exchange_rate" => qa[:exchange_rate],
        "package_price" => item_total_stmt(it[:package_price]),
        "part_price"    => item_total_stmt(it[:part_price]),
        "item_code"     => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_item_code.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "model"         => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_model.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "sub_code"      => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_sub_code.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "part_name"     => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_part_name.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "customer_code" => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_cust_code.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "unit_price"    => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_unit_price_stmt.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "total_approve_file"    => Arel.sql("(SELECT COUNT(*) FROM #{TbQuotationApproveFile.table_name} WHERE tb_quotation_uuid = #{TbQuotation.table_name}.uuid)"),
        "total_calculate_file"  => Arel.sql("(SELECT COUNT(*) FROM #{TbQuotationCalculationFile.table_name} WHERE tb_quotation_uuid = #{TbQuotation.table_name}.uuid)"),
      }

      stmt = qa.project(project_stmt projects).where(qa[:quotation_no].in Arel.sql("(
        SELECT distinct(quotation_no) FROM (#{stmt.to_sql}) AA )

      ")).join(ur).on(ur[:uuid].eq(qa[:created_by]))
        .order(qa[:quotation_no])

      RefCustomer.left_join_me stmt, ct, qa
      RefFreightTerm.left_join_me stmt, ft, qa

      rows = []
      result_rows(stmt).each{|row|
        tmp = JSON.parse row.to_json
        tmp["total_price"] = tmp["part_price"].to_s.to_d + tmp["package_price"].to_s.to_d
        rows.push tmp
      }
      result[:rows] = rows
    else
      result[:rows] = result_rows stmt 
    end

    result[:total] = result_total stmt  
    

  end

  def create_add_item result
    ret = {}
    index_item_data ret
    ori_recs = []
    if params[:records].is_a? Array 
      params[:records].each{|rec|
        tmp = {}
        rec.each{|k, v|
          tmp[k] = v unless k == 'id'
        }
        ori_recs.push tmp
      }
    end
    result[:rows] = [{file_hash: ''}] + ori_recs + ret[:rows]
  end

  def __quotation_item result, values
    return unless result[:valid]
    line_error = {}
    if values.is_a? Array 
      values.each{|item|
        m = yield item if block_given?
        #unless m.blank?
          [
            "row_no", "item_code", "ref_model_uuid", "sub_code", "customer_code", "ref_part_name_uuid", 
            "part_price", "package_price", "ref_unit_price_uuid", "po_reference", "remark"].each{|c|
              m[c.to_sym] = item[c]
            }

          m.file_hash       = 'edit'

          unless m.valid?
            result[:valid] = false

            _line = "line_#{m.row_no}"
            line_error[_line] = [] if line_error[_line].nil?
            m.errors.messages.each{|attr, msgs|
              if msgs.is_a? Array
                msgs.each{|msg| line_error[_line].push msg }
              end
            }
            result[:html] = TbQuotationItem.xls_html_invalid_formatter line_error
          else
            m.save!
          end
        #end
      }
    end
  end

  def __quotation_data n, result
    user = current_user

    n.ref_customer_uuid     = params[:data][:customer]
    n.issue_date            = params[:data][:issue_date]
    n.ref_freight_term_uuid = params[:data][:freight_term]
    n.exchange_rate         = params[:data][:exchange_rate]
    n.updated_by            = user.uuid
  
    edit_ids = [] 
    edits = (params[:data] || {})[:edit_items]
    if edits.is_a? Array 
      edits.each{|item|
        edit_ids.push item["record_id"] unless item["record_id"].blank?
      }  
    end
    if edit_ids.size > 0
      TbQuotationItem.where(quotation_uuid: n.uuid).where(file_hash: 'edit').where.not(id: edit_ids).delete_all 
    else
      TbQuotationItem.where(quotation_uuid: n.uuid).where(file_hash: 'edit').delete_all
    end

    __quotation_item result, (params[:data] || {})[:new_items] do |item|
      m = TbQuotationItem.new
      m.created_by = user.uuid
      m.updated_by = user.uuid
      m.quotation_uuid  = n.uuid 
      m
    end

    __quotation_item result, edits do |item|
      m = TbQuotationItem.find item["record_id"]
      unless m.blank?
        m.updated_by = user.uuid 
        m
      else
        nil
      end
    end
    
  end

  def create_quotation result
    result[:valid] = true
    n = TbQuotation.new
    n.uuid = params[:data][:uuid]
    __quotation_data n, result
    n.quotation_no  = params[:data][:quotation_no]
    n.created_by    = n.updated_by
    n.save! if result[:valid]

    raise ActiveRecord::Rollback unless data_valid
  end

  def destroy_approve_file result
    TbQuotationApproveFile.where(id: params[:id]).delete_all
  end

  def destroy_calculation_file result
    TbQuotationCalculationFile.where(id: params[:id]).delete_all
  end

  def update_remove_excel_items result
    records = params[:records]
    ori_recs = []
    if records.is_a? Array
      tmp = {}
      records.each{|k, v| tmp[k] = v unless k == 'id' }
      ori_recs.push tmp
    end
    ret = {}
    TbQuotationItem.where(quotation_uuid: params[:id]).where.not(quotation_uuid: 'edit').delete_all
    index_item_data ret
    result[:rows] = ori_recs + ret[:rows]
  end

  def store_file n
    user = current_user
    n.tb_quotation_uuid = params[:uuid]
    n.file_hash = params[:id]
    n.file_name = params[:filename]
    n.created_by = user.uuid
    n.updated_by = user.uuid
    n.save!
  end

  def show_file model, result
    result[:rows] = []
    model.where(tb_quotation_uuid: params[:id]).order(:file_name).each{|row|
      result[:rows].push({
        filename: row.file_name,
        hash: row.file_hash,
        record_id: row.id,
        uploaded: row.created_at.strftime('%d/%m/%Y %H:%M:%S')
        })
    }
  end

  def update_store_calculation_file result
    store_file TbQuotationCalculationFile.new
  end

  def update_store_approve_file result
    store_file TbQuotationApproveFile.new
  end

  def show_calculation_file result
    show_file TbQuotationCalculationFile, result
  end

  def show_approve_file result
    show_file TbQuotationApproveFile, result
  end

  def update_store_approve_file result
    user = current_user
    n = TbQuotationApproveFile.new
    n.tb_quotation_uuid = params[:uuid]
    n.file_hash = params[:id]
    n.file_name = params[:filename]
    n.created_by = user.uuid
    n.updated_by = user.uuid
    n.save!
  end

  def show_form_view result
    create_form_create result

    n = TbQuotation.where(uuid: params[:id]).first
    
    result[:data][:id]                    = n.id
    result[:data][:uuid]                  = n.uuid
    result[:data][:lock_version]          = n.lock_version
    result[:data][:quotation_no]          = n.quotation_no
    result[:data][:ref_customer_uuid]     = n.ref_customer_uuid
    result[:data][:issue_date]            = n.issue_date
    result[:data][:ref_freight_term_uuid] = n.ref_freight_term_uuid
    result[:data][:exchange_rate]         = n.exchange_rate

    User.where(uuid: n.created_by).each{|row|
      result[:data][:created_by] = row.first_name.to_s + " " + row.last_name.to_s
    }
    
  end

  def create_form_create result
    result[:data] = {}
    result[:data][:uuid]          = UUID.generate
    result[:data][:customers]     = RefCustomer.ref_dropdown
    result[:data][:freight_terms] = RefFreightTerm.ref_dropdown
    result[:data][:unit_prices]   = RefUnitPrice.ref_dropdown
    result[:data][:models]        = RefModel.ref_dropdown
    result[:data][:part_names]    = RefPartName.ref_dropdown
  end

  def update_quotation result
    result[:valid] = true
    n = TbQuotation.find params[:id]   
    __quotation_data n, result
    n.save! if result[:valid]

    raise ActiveRecord::Rollback unless result[:valid]
  end

  def create_detail result
    n = TbQuotationItem.new
    n.fn_create_record_data params[:data]
    p n
  end

  def update_process_file result
    user = current_user
    row = FileUpload.where(file_hash: params[:id]).first
    if row.blank?
      result[:error] = "File not found!"
    else
      ret = TbQuotationItem.validate_xml row, params[:quotation_uuid], user.uuid, user.uuid
      result[:valid] = ret.first
      unless ret.first
        result[:html] = ret[2]
        raise ActiveRecord::Rollback
      end
    end
  end

  def index_item_data result
    it = TbQuotationItem.arel_table
    pt = RefPartName.arel_table
    md = RefModel.arel_table
    ut = RefUnitPrice.arel_table

    stmt = it.project(project_stmt({
      "row_no"        => it[:row_no],
      "record_id"     => it[:id],
      "file_hash"     => it[:file_hash],
      "item_code"     => it[:item_code],
      "sub_code"      => it[:sub_code],
      "part_price"    => it[:part_price],
      "po_reference"  => it[:po_reference],
      "remark"        => it[:remark],
      "package_price" => it[:package_price],
      "customer_code" => it[:customer_code],
      "ref_unit_price_uuid" => it[:ref_unit_price_uuid],
      "total_price"   => Arel.sql("(COALESCE(#{it.table_name}.part_price, 0) + COALESCE(#{it.table_name}.package_price, 0)) "),
      "ref_part_name_uuid" => it[:ref_part_name_uuid],
      "ref_model_uuid"=> it[:ref_model_uuid]

      })).where(it[:quotation_uuid].eq params[:uuid])
    .order(Arel.sql("CASE #{it.table_name}.file_hash WHEN 'edit' THEN 0 ELSE 1 END"), it[:row_no])

    RefPartName.join_me stmt, pt, it
    RefModel.join_me stmt, md, it
    RefUnitPrice.join_me stmt, ut, it

    rows = TbQuotationItem.find_by_sql(stmt)
    result[:rows] = rows
  end
end
