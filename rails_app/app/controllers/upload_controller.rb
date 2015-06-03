class UploadController < ApplicationController
  def file_upload

    begin
      m = FileUpload.store(params[:file].tempfile.read, params[:file].content_type)
      FileUploadMetum.file m, params[:file].original_filename, current_user
      ret = { data: { hash: m.file_hash, filename: params[:file].original_filename }}
    rescue Exception => e
      ret = { error: { message: e.message, backtrace: e.backtrace } }
    end
    
    render json: ret
  end

  def download
    FileUpload.where(file_hash: params[:id]).limit(1).each{|f|
      send_data(f.get_file_data, {filename: params[:filename], type: params[:type] })
    }
  end

  def get_file
    path = Rails.root.join('tmp', params[:id])
    data = File.open(path, 'rb'){|f| f.read }
    File.delete path
    send_data(data, {filename: params[:filename], type: params[:type] })
  end

IMPORT_CONFIG = {
  data_row: 1,
  data_col: 0,
  columns: {
    quotation_no:   { title: "Quotation No."  },
    customer:       { title: "Customer",      },
    create_person:  { title: "Create Person", },
    issue_date:     { title: "Issue Date"     },
    freight_term:   { title: "Freight Term"   },
    exchange_rate:  { title: "Exch.Rate"      },
    item_code:      { title: "Item Code"      },
    model:          { title: "Model"          },
    sub_code:       { title: "Sub Code"       },
    customer_code:  { title: "Customer Code"  },
    part_name:      { title: "Part Name"      },
    part_price:     { title: "Part Price"     },
    package_price:  { title: "Package Price"  },
    total_price:    { title: "Total Price"    },
    unit_price:     { title: "Unit Price"     },
    po_reference:   { title: "PO Reference"   },
    remark:         { title: "Ramark"         }
  }
}

  def _c name, row
    index = -1 
    ret = -1
    IMPORT_CONFIG[:columns].each{|k, v|
      index += 1
      if k.to_s == name.to_s
        ret = index
      end
    }
    row[ret]
  end

  def __import file_path
    user = current_user

    is_break = false
     
    csv_data = []

    CSV.foreach(file_path) do |row|
 
      null_count = 1
      row.each{|col, col_index|
        null_count += 1 if col.blank?
        is_break = (null_count >= (row.size - 1))
          
      }
      break if is_break

      csv_data.push row
      
    end

    csv_data.each_with_index{|row, row_index|
      qa = TbQuotation.where(quotation_no: _c(:quotation_no, row)).first
      unless qa.blank?
        TbQuotationItem.where(quotation_uuid: qa.uuid).delete_all
      end
      TbQuotation.where(quotation_no: _c(:quotation_no, row)).delete_all
    }

    csv_data.each_with_index{|row, row_index|
      next if row_index == 0  

      qa = TbQuotation.where(quotation_no: _c(:quotation_no, row)).first
      if qa.blank?
        qa = TbQuotation.new
        qa.uuid = UUID.generate
        qa.created_by = user.uuid
      end
 
      qa.quotation_no = _c(:quotation_no, row)
 
      qa.ref_customer_uuid = RefCustomer.ref_get(_c(:customer, row), 'importer').uuid
      qa.issue_date = Date.strptime(_c(:issue_date, row), "%d-%b-%y")
      qa.ref_freight_term_uuid = RefFreightTerm.ref_get(_c(:freight_term, row), 'importer').uuid
      qa.exchange_rate = _c(:exchange_rate, row)
      qa.updated_by = user.uuid

      qa.save!

      ## items ###
      
      TbQuotationItem.create!({quotation_uuid: qa.uuid,
        created_by: user.uuid,
        updated_by: user.uuid,
        item_code: _c(:item_code, row ),
        ref_model_uuid: RefModel.ref_get(_c(:model, row), 'importer').uuid,
        sub_code: _c(:sub_code, row),
        customer_code: _c(:customer_code, row ),
        part_price: _c(:part_price, row),
        package_price: _c(:package_price, row ),
        ref_unit_price_uuid: RefUnitPrice.ref_get(_c(:unit_price, row)).uuid,
        po_reference: _c(:po_reference, row ),
        remark: _c(:remark, row),
        file_hash: 'importer',
        row_no: row_index,
        part_name: _c(:part_name, row)

      })
    }

  end

  def import_excel
    error = nil
    begin
      ActiveRecord::Base.transaction do
        __import params[:excel].tempfile.path
      end
    rescue Exception => e
      error = e.message
      puts e.message
      puts e.backtrace
    end

    render json: { error: error }
  end
end
