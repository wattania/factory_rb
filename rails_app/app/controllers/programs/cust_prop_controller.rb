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

  def __form_data n, pdata
    ["description", "ref_request_by_uuid", "ref_department_uuid", "request_qty", "ref_unit_uuid", "cmd_issue_date",
      "require_date", "status", "doc_approved_file_name", "doc_approved_file_hash"
    ].each{|field|
      n[field.to_sym] = pdata[field]
    }

    (1..5).each{|num|
      ["tool_receive_date", "invoice_no", "receive_qty"].each{|field|
        n["#{field}_0#{num}".to_sym] = pdata["#{field}_0#{num}"]
      }
    }
  end

  def create_data result
    user = current_user
    n = TbCustomerProperty.new 
    __form_data n, (params[:data] || {})
    n.uuid        = params[:data]["uuid"]
    n.document_no = params[:data]["document_no"]
    n.created_by  = user.uuid 
    n.updated_by  = user.uuid
    n.save!
  end

  def update_data result
    user = current_user
    n = TbCustomerProperty.find params[:id] 
    __form_data n, (params[:data] || {})
    n.updated_by  = user.uuid
    n.save!
  end

end
