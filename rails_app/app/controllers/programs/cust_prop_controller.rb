class Programs::CustPropController < ResourceHelperController
  def create_export_all result 
    result[:hash] = TbCustomerProperty.export_all params[:filter]
  end

  def index_list result
    TbCustomerProperty.index_list_stmt
    filter = {}
    unless params[:filter].blank?
      filter = JSON.parse(params[:filter])
    end

    if params[:group_by_document_no].to_s == "true"
      stmt = TbCustomerProperty.index_list_stmt filter, true
      result[:rows] = result_rows stmt
    else
      stmt = TbCustomerProperty.index_list_stmt filter
      result[:rows] = result_rows stmt 
    end

    result[:total] = result_total stmt 
  end

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

  def __form_values
    [ "description", "ref_request_by_uuid", "ref_department_uuid", "request_qty", "ref_unit_uuid", "cmd_issue_date",
      "require_date", "status", "doc_approved_file_name", "doc_approved_file_hash", "remark"
    ]
  end

  def show_form result
    n = TbCustomerProperty.find params[:id]
    create_form result
    result[:data][:uuid] = n.uuid
    __form_values.each{|vv|
      result[:data][vv] = n[vv.to_sym]
    }
    result[:data][:document_no] = n.document_no
    result[:data][:id] = n.id
    result[:data][:lock_version] = n.lock_version

    result[:data][:grid] = []
    total_qty = 0
    TbCustomerTool.where(customer_prop_uuid: n.uuid).order("row_no NULLS LAST").each_with_index{|row| 
      tmp = JSON.parse row.to_json
      tmp["record_id"] = row.id
      result[:data][:grid].push tmp
      total_qty += row.receive_qty.to_s.to_d
    }

    (1..(5 - result[:data][:grid].size)).each{|num|
      result[:data][:grid].push({tool_receive_date: nil, invoice_no: '', receive_qty: nil})
    }

    result[:data][:balance_qty]  = n.request_qty.to_s.to_d - total_qty
    result[:data][:deleted_at] = n.deleted_at

  end

  def __form_data n, pdata
    if params[:data]["deleted_at"]
      if n.deleted_at.blank?
        n.deleted_at = DateTime.current 
      end
    else
      n.deleted_at = nil
    end

    __form_values.each{|field|
      n[field.to_sym] = pdata[field]
    }

    if pdata["grid"].is_a? Array
      tl = TbCustomerTool.new
      tl.customer_prop_uuid = n.uuid
    end

    if pdata["grid"].is_a? Array 
      pdata["grid"].each_with_index{|row, row_index|  
        tl = nil
        unless row["id"].blank?
          tl = TbCustomerTool.find row["id"]
        else
          tl = TbCustomerTool.new
          tl.customer_prop_uuid = n.uuid
        end

        unless tl.blank?
          
          ["tool_receive_date", "invoice_no", "receive_qty", "row_no"].each{|field|
            tl[field.to_sym] = row[field]
          }

          skip = false
          if tl.tool_receive_date.blank? and tl.invoice_no.blank?
            skip = true if tl.receive_qty.to_s.to_d == 0
          end

          unless skip 
            if tl.valid?
              tl.save!
            else
              puts " invalid! "
              raise tl.errors.message
            end
          else
            tl.destroy unless tl.new_record?
          end
        end
      }
    end
  end

  def create_data result
    user = current_user
    n = TbCustomerProperty.new 
    n.uuid        = params[:data]["uuid"]
    __form_data n, (params[:data] || {})
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
