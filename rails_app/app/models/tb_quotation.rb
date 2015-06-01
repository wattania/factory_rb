class TbQuotation < ActiveRecord::Base
  def download_details_excel
    uuid = UUID.generate
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "#{self.quotation_no}") do |sheet|
        sheet.add_row ["First Column", "Second", "Third"]
        #sheet.add_row [1, 2, 3]
        
      end
      p.serialize(Rails.root.join 'tmp', uuid)
    end
    uuid
  end
end
