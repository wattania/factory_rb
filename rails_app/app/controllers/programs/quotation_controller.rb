class Programs::QuotationController < ResourceHelperController
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

    puts
    puts stmt.to_sql
    puts

    rows = TbQuotationItem.find_by_sql(stmt)
    result[:rows] = rows
  end
end
