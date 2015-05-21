class Programs::QuotationController < ResourceHelperController
  def create_form_create result
    result[:data] = {}
    result[:data][:customers]     = RefCustomer.dropdown
    result[:data][:freight_terms] = RefFreightTerm.dropdown
    result[:data][:unit_prices]   = RefUnitPrice.dropdown
    result[:data][:models]        = RefModel.dropdown
  end

  def update_process_file result
    file_path = FileUpload.get_path_by_hash params[:id]
    TbQuotationItem.validate_xml file_path.to_s

  end
end
