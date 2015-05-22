class Programs::QuotationController < ResourceHelperController
  def create_form_create result
    result[:data] = {}
    result[:data][:customers]     = RefCustomer.ref_dropdown
    result[:data][:freight_terms] = RefFreightTerm.ref_dropdown
    result[:data][:unit_prices]   = RefUnitPrice.ref_dropdown
    result[:data][:models]        = RefModel.ref_dropdown
  end

  def update_process_file result
    file_path = FileUpload.get_path_by_hash params[:id]
    TbQuotationItem.validate_xml file_path.to_s

  end
end
