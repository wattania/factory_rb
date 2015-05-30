class Programs::QuotationController < ResourceHelperController
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
      "freight_term"  => ft[:display_name],
      "exchange_rate" => qa[:exchange_rate],
      "item_code"     => { field: it[:item_code], filter: :like },
      "sub_code"      => it[:sub_code],
      "part_price"    => it[:part_price],
      "po_reference"  => it[:po_reference],
      "remark"        => it[:remark],
      "package_price" => it[:package_price],
      "total_price"   => Arel.sql("(COALESCE(#{it.table_name}.part_price, 0) + COALESCE(#{it.table_name}.package_price, 0)) "),
      "customer_code" => { field: it[:customer_code], filter: :like },
      "unit_price"    => ut[:display_name],
      "part_name"     => pt[:display_name],
      "model"         => md[:display_name],
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

    result[:rows] = result_rows stmt 
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

  def __quotation_data n, result
    data_valid = true
    result[:valid] = data_valid

    user = current_user

    n.ref_customer_uuid     = params[:data][:customer]
    n.issue_date            = params[:data][:issue_date]
    n.ref_freight_term_uuid = params[:data][:freight_term]
    n.exchange_rate         = params[:data][:exchange_rate]
    n.updated_by            = user.uuid

    line_error = {}
    if (params[:data] || {})[:edit_items].is_a? Array
      (params[:data] || {})[:edit_items].each_with_index{|item, index|
    
        m = TbQuotationItem.new
        m.created_by = user.uuid
        m.updated_by = user.uuid
        m.row_no     = (index + 1)
        m.quotation_uuid  = n.uuid 
        m.item_code       = item["item_code"]
        m.ref_model_uuid  = item["model"]
        m.sub_code        = item["sub_code"]
        m.customer_code   = item["customer_code"]
        m.ref_part_name_uuid = item["part_name"]
        m.part_price      = item["part_price"]
        m.package_price   = item["package_price"]
        m.ref_unit_price_uuid = item["unit_price"]
        m.po_reference    = item["po_reference"]
        m.remark          = item["remark"]
        m.file_hash       = 'edit'
        
        unless m.valid?
          data_valid = false

          _line = "line_#{index + 1}"
          line_error[_line] = [] if line_error[_line].nil?
          m.errors.messages.each{|attr, msgs|
            if msgs.is_a? Array
              msgs.each{|msg| line_error[_line].push msg }
            end
          }
          result[:valid] = data_valid
          result[:html] = TbQuotationItem.xls_html_invalid_formatter line_error
        else
          m.save!
        end
      }
    end

  end

  def create_quotation result
    n = TbQuotation.new
    n.uuid                  = params[:data][:uuid]
    data_valid = __quotation_data n, result
    n.quotation_no          = params[:data][:quotation_no]
    n.created_by = n.updated_by
    n.save! if data_valid

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
    n = TbQuotation.find params[:id]   
    data_valid = __quotation_data n, result
    n.save! if data_valid

    raise ActiveRecord::Rollback unless data_valid
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
      "customer_code" =>it[:customer_code],
      "unit_price"    => ut[:display_name],
      "total_price"   => Arel.sql("(COALESCE(#{it.table_name}.part_price, 0) + COALESCE(#{it.table_name}.package_price, 0)) "),
      "part_name"     => pt[:display_name],
      "model"         => md[:display_name]

      })).where(it[:quotation_uuid].eq params[:uuid])
    .order(it[:row_no])

    RefPartName.join_me stmt, pt, it
    RefModel.join_me stmt, md, it
    RefUnitPrice.join_me stmt, ut, it

    rows = TbQuotationItem.find_by_sql(stmt)
    result[:rows] = rows
  end
end
