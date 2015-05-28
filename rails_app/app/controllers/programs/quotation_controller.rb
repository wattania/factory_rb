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

  def create_quotation result
    user = current_user

    n = TbQuotation.new
    n.uuid                  = params[:data][:uuid]
    n.quotation_no          = params[:data][:quotation_no]
    n.ref_customer_uuid     = params[:data][:customer]
    n.issue_date            = params[:data][:issue_date]
    n.ref_freight_term_uuid = params[:data][:freight_term]
    n.exchange_rate         = params[:data][:exchange_rate]
    n.created_by            = user.uuid 
    n.updated_by            = user.uuid
    n.save!

  end

  def destroy_approve_file result
    TbQuotationApproveFile.where(id: params[:id]).delete_all
  end

  def destroy_calculation_file result
    TbQuotationCalculationFile.where(id: params[:id]).delete_all
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
  end

  def update_quotation result
    user = current_user

    n = TbQuotation.find params[:id]  
    n.ref_customer_uuid     = params[:data][:customer]
    n.issue_date            = params[:data][:issue_date]
    n.ref_freight_term_uuid = params[:data][:freight_term]
    n.exchange_rate         = params[:data][:exchange_rate]
    n.updated_by            = user.uuid
    n.save!
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
      "item_code"     => it[:item_code],
      "sub_code"      => it[:sub_code],
      "part_price"    => it[:part_price],
      "po_reference"  => it[:po_reference],
      "remark"        => it[:remark],
      "package_price" => it[:package_price],
      "customer_code" =>it[:customer_code],
      "unit_price"    => ut[:display_name],
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
