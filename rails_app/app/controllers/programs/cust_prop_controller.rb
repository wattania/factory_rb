class Programs::CustPropController < ResourceHelperController

  def create_form result
    result[:data] = {}
    result[:data][:uuid]          = UUID.generate
    result[:data][:request_bies]  = RefRequestBy.ref_dropdown
    result[:data][:departments]   = RefDepartment.ref_dropdown
    result[:data][:units]         = RefUnit.ref_dropdown
    result[:data][:grid]          = [
      {tool_receive_date: nil, invoice_no: '', receive_qty: nil},
      {tool_receive_date: nil, invoice_no: '', receive_qty: nil},
      {tool_receive_date: nil, invoice_no: '', receive_qty: nil},
      {tool_receive_date: nil, invoice_no: '', receive_qty: nil},
      {tool_receive_date: nil, invoice_no: '', receive_qty: nil},
    ]
  end

end
