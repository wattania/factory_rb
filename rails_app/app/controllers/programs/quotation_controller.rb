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
      "quotation_no"  => qa[:quotation_no],
      "customer"      => ct[:display_name],
      "created_by"    => XModelUtils.desc(ur[:first_name], ur[:last_name], ' '),
      "issue_date"    => qa[:issue_date],
      "freight_term"  => ft[:display_name],
      "exchange_rate" => qa[:exchange_rate],
      "item_code"     => it[:item_code],
      "sub_code"      => it[:sub_code],
      "part_price"    => it[:part_price],
      "po_reference"  => it[:po_reference],
      "remark"        => it[:remark],
      "package_price" => it[:package_price],
      "customer_code" => it[:customer_code],
      "unit_price"    => ut[:display_name],
      "part_name"     => pt[:display_name],
      "model"         => md[:display_name]
    }

    stmt = qa.project(project_stmt projects)
      .join(ur).on(ur[:uuid].eq(qa[:created_by]))
      .join(it).on(it[:quotation_uuid].eq(qa[:uuid]))


    RefCustomer.join_me stmt, ct, qa
    RefFreightTerm.join_me stmt, ft, qa

    RefPartName.join_me stmt, pt, it
    RefModel.join_me stmt, md, it
    RefUnitPrice.join_me stmt, ut, it

    #RefPartName.join_me stmt, pt, it
    #RefModel.join_me stmt, md, it
    #RefUnitPrice.join_me stmt, ut, it

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

  def create_form_create result
    result[:data] = {}
    result[:data][:uuid]          = UUID.generate
    result[:data][:customers]     = RefCustomer.ref_dropdown
    result[:data][:freight_terms] = RefFreightTerm.ref_dropdown
    result[:data][:unit_prices]   = RefUnitPrice.ref_dropdown
    result[:data][:models]        = RefModel.ref_dropdown
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
