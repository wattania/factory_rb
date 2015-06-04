module FuncExportExcel
  module FuncExportExcelClassMethods  
    def __export_excel a_datas, a_config, a_sheet_name = ""
      p = Axlsx::Package.new
      wb = p.workbook

      uuid = UUID.generate
      wb.add_worksheet(:name => a_sheet_name) do |sheet|

        header = []
        a_config.each{|k, config| header.push config[:title] }

        header_style = yield :header_style, header if block_given?
        if header_style.blank?
          sheet.add_row header
        else
          sheet.add_row header, style: header_style
        end
        #sheet.add_row header, style: Axlsx::STYLE_THIN_BORDER
        
        a_datas.each{|item|
          row = [] 
          types = []
          a_config.each_with_index{|values, index|
            name    = values.first
            conf    = values.last

            row.push item[name]
            types.push conf[:type]
          }
          
          sheet.add_row row, types: types
        }
      end

      p.serialize(Rails.root.join 'tmp', uuid)
      uuid

    end
  end

  def self.included base
    base.extend FuncExportExcelClassMethods
  end
end