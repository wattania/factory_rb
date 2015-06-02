class TbQuotation < ActiveRecord::Base
  validates :quotation_no, uniqueness: true
  
  def items_stmt
    it = TbQuotationItem.arel_table 
    md = RefModel.arel_table
    ut = RefUnitPrice.arel_table

    stmt = it.project(XModelUtils.project_stmt({
      "row_no"        => it[:row_no],
      "record_id"     => it[:id],
      "file_hash"     => it[:file_hash],
      "item_code"     => it[:item_code],
      "sub_code"      => it[:sub_code],
      "part_price"    => it[:part_price],
      "po_reference"  => it[:po_reference],
      "remark"        => it[:remark],
      "package_price" => it[:package_price],
      "customer_code" => it[:customer_code],
      "ref_unit_price_uuid" => it[:ref_unit_price_uuid],
      "unit"          => ut[:display_name],
      "total_price"   => Arel.sql("(COALESCE(#{it.table_name}.part_price, 0) + COALESCE(#{it.table_name}.package_price, 0)) "),
      "part_name"     => it[:part_name],
      "ref_model_uuid"=> it[:ref_model_uuid],
      "model"         => md[:display_name]

      })).where(it[:quotation_uuid].eq self.uuid)
    .order(Arel.sql("CASE #{it.table_name}.file_hash WHEN 'edit' THEN 0 ELSE 1 END"), it[:row_no])
 
    RefModel.join_me stmt, md, it
    RefUnitPrice.join_me stmt, ut, it

    stmt
  end

  def download_details_excel_
    uuid = UUID.generate
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "#{self.quotation_no}") do |sheet|
        __create_details_sheet sheet
      end
      p.serialize(Rails.root.join 'tmp', uuid)
    end
    uuid
  end

  EXPORT_DETAILS = {
    "item_code"     => {title: "Item Code" },
    "model"         => {title: "Model"},
    "sub_code"      => {title: "Sub code", types: :string},
    "customer_code" => {title: "Customer Code"},
    "part_name"     => {title: "Part name"},
    "part_price"    => {title: "Part price"},
    "package_price" => {title: "Package price"},
    "unit"          => {title: "Unit price"},
    "po_reference"  => {title: "PO Reference"},
    "remark"        => {title: "Remark"}
  }

  def download_details_excel
    conn = ActiveRecord::Base.connection

    p = Axlsx::Package.new
    wb = p.workbook

    uuid = UUID.generate
    wb.add_worksheet(:name => "#{self.quotation_no}") do |sheet|

      header = []
      EXPORT_DETAILS.each{|k, config|
        header.push config[:title]
      }
      sheet.add_row header, style: Axlsx::STYLE_THIN_BORDER
      
      conn.execute(items_stmt.to_sql).each{|item|
        row = [] 
        EXPORT_DETAILS.each_with_index{|values, index|
          name    = values.first
          conf    = values.last

          row.push item[name]
        }
        
        sheet.add_row row, :types => [nil, nil, :string, :string]
      }
    end

    p.serialize(Rails.root.join 'tmp', uuid)
    uuid
  end



  def __create_details_sheet sheet
    sheet.add_row ["First Column", "Second", "Third"]
    sheet.add_row [1, 2, 3]
    sheet.add_row ['     preserving whitespace']
  end
end
