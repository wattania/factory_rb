#encoding: UTF-8
module FuncValidateHelper
  def func_set_uuid
    self.uuid = UUID.generate if self.uuid.blank?
  end

  def v_duplicate_ref_display_name
    return if self.deleted_at
    if self.class.select(1).where(deleted_at: nil).where(display_name: self.display_name).size > 0
      errors[:display_name] << "Display Name Duplicate!"
    end
  end

  def v_helper_xls_ref_exist attribute_sym, xls_columns
    if self[attribute_sym].blank?
      desc = ((xls_columns[:columns] || []).select{|e| e[:name] == attribute_sym}.first || {})[:text]
      attr_text = send("#{attribute_sym}_val")
      errors[attribute_sym] << "#{desc} '#{attr_text}' ไม่มีในระบบ"
    end
  end

  def v_helper_xls_presence attribute_sym, xls_columns
    if self[attribute_sym].blank?
      desc = ((xls_columns[:columns] || []).select{|e| e[:name] == attribute_sym}.first || {})[:text]
      errors[attribute_sym] << "'#{desc}' can't be blank"
    end
  end

  def v_helper_xls xls_columns
    (xls_columns[:columns] || []).each{|conf|
      field = conf[:name]
      validates = conf[:validates] || []
      validates.each{|v_name|

        case v_name
        when :no_blank
          if conf[:ref_value]
            v_helper_xls_ref_exist field, xls_columns
          else
            v_helper_xls_presence field, xls_columns
          end
        end

      }
    }
  end

  module FuncValidateHelperClassMethods
    def xls_html_invalid_formatter errors

      table_rows = []
      errors.each{|line_no, msgs|
        table_rows.push("
          <tr>
            <td>#{line_no.split('_').last}</td>
            <td>#{msgs.join '</br>'}</td>
          </tr>
          ")
      }

            html = "
        <font color=red><b>Invalid!!</b></font>
       <table border=\"1\" style=\"width:100%\">
  <tr>
    <td>Line No.</td>
    <td>Message</td>
  </tr>
  #{table_rows.join('')}
</table> 
" 
      html
    end

    def v_validate_xml file_upload, tmp_file, xls_columns
      data_valid = true
      
      line_error = {}
      
      tmp_file.write file_upload.get_file_data
      tmp_file.rewind

      xlsx = Roo::Excelx.new tmp_file.path
      #xlsx.default_sheet = xlsx.sheets[0]
      ((xlsx.first_row + (xls_columns[:data_row_index] || 0))..xlsx.last_row).each_with_index do |row, row_index|
        
        item = TbQuotationItem.new
        item.row_no = row_index + 1
        item.file_hash = file_upload.file_hash

        (xls_columns[:columns] || []).each_with_index{|col_config, col_index|
          val = xlsx.row(row)[col_index]
          cell_type = (xlsx.celltype row_index, col_index) || :string

          unless cell_type.blank?
            require_cell_type = col_config[:cell_type] || :string
            unless require_cell_type == cell_type
              data_valid = false
              _line = "line_#{row_index + 1}"

              line_error[_line] = [] if line_error[_line].blank?
              m = "<b>#{col_config[:text]}</b>: Cell Type Invalid! (Data=#{cell_type}, Require=#{require_cell_type})"
              puts m
              p val
              puts
              line_error[_line].push 
            end
          end
          item.set_value_from_xml col_config[:name], val
        }

        yield item, row if block_given?
   
        unless item.valid?
          data_valid = false

          _line = "line_#{row_index + 1}"
          line_error[_line] = [] if line_error[_line].blank?
          item.errors.messages.each{|attr, msgs|
            if msgs.is_a? Array
              msgs.each{|msg|
                line_error[_line].push msg
              }
            end
          }
        else
          item.save!
        end
      end

      [data_valid, line_error, xls_html_invalid_formatter(line_error) ]
    end
  end

  def self.included base
    base.extend FuncValidateHelperClassMethods
  end
end