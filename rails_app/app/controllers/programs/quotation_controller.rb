class Programs::QuotationController < ResourceHelperController
  def create_export_all result
    result[:hash] = TbQuotation.export_all params[:filter]
  end

  def index_download_details result
    n = TbQuotation.where(uuid: params[:uuid]).first 
    unless n.blank?
      result[:hash] = n.download_details_excel
    end
  end

  def index_list result
    FileUpload.remove_junk_file
    
    filter = {}
    unless params[:filter].blank?
      filter = JSON.parse(params[:filter])
    end

    if params[:group_quotation].to_s == "true"
      stmt = TbQuotation.index_list_stmt filter, true
      rows = []
      result_rows(stmt).each{|row|
        tmp = JSON.parse row.to_json
        tmp["total_price"] = tmp["part_price"].to_s.to_d + tmp["package_price"].to_s.to_d
        rows.push tmp
      }
      result[:rows] = rows
    else
      stmt = TbQuotation.index_list_stmt filter
      result[:rows] = result_rows stmt 
    end

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

  def __quotation_item result, values
    return unless result[:valid]
    line_error = {}
    if values.is_a? Array 
      values.each{|item|
        m = yield item if block_given?
        #unless m.blank?
          [
            "row_no", "item_code", "ref_model_uuid", "sub_code", "customer_code", "part_name", 
            "part_price", "package_price", "ref_unit_price_uuid", "po_reference", "remark"].each{|c|
              m[c.to_sym] = item[c]
            }

          m.file_hash       = 'edit'

          unless m.valid?
            result[:valid] = false

            _line = "line_#{m.row_no}"
            line_error[_line] = [] if line_error[_line].nil?
            m.errors.messages.each{|attr, msgs|
              if msgs.is_a? Array
                msgs.each{|msg| line_error[_line].push msg }
              end
            }
            result[:html] = TbQuotationItem.xls_html_invalid_formatter line_error
          else
            m.save!
          end
        #end
      }
    end
  end

  def __quotation_data n, result
    user = current_user

    n.ref_customer_uuid     = params[:data][:customer]
    n.issue_date            = params[:data][:issue_date]
    n.ref_freight_term_uuid = params[:data][:freight_term]
    n.exchange_rate         = params[:data][:exchange_rate]
    if params[:data][:deleted_at]
      if n.deleted_at.blank?
        n.deleted_at            = DateTime.current 
      end
    else
      n.deleted_at = nil
    end
    
    n.updated_by            = user.uuid
  
    edit_ids = [] 
    edits = (params[:data] || {})[:edit_items]
    if edits.is_a? Array 
      edits.each{|item|
        edit_ids.push item["record_id"] unless item["record_id"].blank?
      }  
    end
    if edit_ids.size > 0
      TbQuotationItem.where(quotation_uuid: n.uuid).where(file_hash: 'edit').where.not(id: edit_ids).delete_all 
    else
      TbQuotationItem.where(quotation_uuid: n.uuid).where(file_hash: 'edit').delete_all
    end

    __quotation_item result, (params[:data] || {})[:new_items] do |item|
      m = TbQuotationItem.new
      m.created_by = user.uuid
      m.updated_by = user.uuid
      m.quotation_uuid  = n.uuid 
      m
    end

    __quotation_item result, edits do |item|
      m = TbQuotationItem.find item["record_id"]
      unless m.blank?
        m.updated_by = user.uuid 
        m
      else
        nil
      end
    end
    
  end

  def create_quotation result
    result[:valid] = true
    n = TbQuotation.new
    n.uuid = params[:data][:uuid]
    __quotation_data n, result
    n.quotation_no  = params[:data][:quotation_no]
    n.created_by    = n.updated_by
    n.save! if result[:valid]

    raise ActiveRecord::Rollback unless result[:valid]
  end

  def destroy_approve_file result
    TbQuotationApproveFile.where(id: params[:id]).delete_all
  end

  def destroy_calculation_file result
    TbQuotationCalculationFile.where(id: params[:id]).delete_all
  end

  def destroy_quotation result
    n = TbQuotation.find params[:id]
    TbQuotation.where(id: params[:id]).delete_all
    TbQuotationItem.where(quotation_uuid: n.uuid).delete_all
    TbQuotationApproveFile.where(tb_quotation_uuid: n.uuid).delete_all
    TbQuotationCalculationFile.where(tb_quotation_uuid: n.uuid).delete_all
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
    user = current_user
    model.where(tb_quotation_uuid: params[:id]).order(:file_name).each{|row|
      result[:rows].push({
        filename: row.file_name,
        hash: row.file_hash,
        record_id: row.id,
        uploaded: row.created_at.in_time_zone(user.get_timezone).strftime("%d/%m/%Y %H:%M:%S")
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
    result[:data][:deleted_at]            = n.deleted_at
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
    result[:valid] = true
    n = TbQuotation.find params[:id]   
    __quotation_data n, result
    n.save! if result[:valid]

    raise ActiveRecord::Rollback unless result[:valid]
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
    n = TbQuotation.where(uuid: params[:uuid]).limit(0).first
    if n.blank?
      n = TbQuotation.new 
      n.uuid = params[:uuid]
    end

    result[:rows] = TbQuotationItem.find_by_sql(n.items_stmt)
  end
end
