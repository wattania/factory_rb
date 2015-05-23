class Programs::QuotationController < ResourceHelperController
  def create_form_create result
    result[:data] = {}
    result[:data][:customers]     = RefCustomer.ref_dropdown
    result[:data][:freight_terms] = RefFreightTerm.ref_dropdown
    result[:data][:unit_prices]   = RefUnitPrice.ref_dropdown
    result[:data][:models]        = RefModel.ref_dropdown
  end

  def update_process_file result

    row = FileUpload.where(file_hash: params[:id]).first
    if row.blank?
      result[:error] = "File not found!"
    else
      TbQuotationItem.validate_xml row
    end
  end
end
