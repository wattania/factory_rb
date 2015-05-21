if defined?(JRUBY_VERSION)
  java_import Java::OrgApachePoiXssfUsermodel::XSSFWorkbook
  java_import Java::OrgApachePoiSsUsermodel::Cell
  java_import Java::OrgApachePoiSsUsermodel::Row
  java_import Java::OrgApachePoiXssfUsermodel::XSSFRow
  java_import Java::OrgApachePoiXssfUsermodel::XSSFSheet
  java_import Java::OrgApachePoiXssfUsermodel::XSSFWorkbook
end

class TbQuotationItem < ActiveRecord::Base
 
  XLSX_COLUMNS = [
    {name: :item_code,           text: 'Item Code'},
    {name: :ref_model_uuid,      text: 'XXModel'},
    {name: :sub_code,            text: 'Sub Code'},
    {name: :customer_code,       text: 'Customer Code'},
    {name: :part_name,           text: 'Part Name'},
    {name: :part_price,          text: 'Part Price'},
    {name: :package_price,       text: 'Package Price'},
    {name: :ref_unit_price_ref,  text: 'XX Unit Price'},
    {name: :po_reference,        text: 'PO reference'},
    {name: :remark,              text: 'Remark'}
  ]
 
  validates :ref_model_uuid, presence: true 
  #validates :item_code, :ref_model_uuid, :sub_code, :customer_code, :part_name, :part_price, :package_price, :ref_unit_price_ref, presence: true 

  def self.human_attribute_name a_attr
    ret = super
    XLSX_COLUMNS.each{|conf| ret = conf[:text] if conf[:name] == a_attr }
    puts "--a--->#{a_attr}->#{ret}"
    ret
  end

  def self.validate_file_name file_name

  end

  def self.validate_xml file_path
    file = Java::JavaIo::File.new file_path
    fis = Java::JavaIo::FileInputStream.new file 
    workbook = XSSFWorkbook.new fis
    if file.is_file and file.exists
      puts "openworkbook.xlsx file open successfully."

      spreadsheet = workbook.get_sheet_at 0
      it = spreadsheet.iterator

      row_index = -1
      while it.has_next
        row_index += 1
        row = it.next.to_java XSSFRow
        next if row_index > 0

        _item = TbQuotationItem.new
        _item.valid?
        p _item.errors.messages

        cell_it = row.cellIterator

        col_index = -1
        while cell_it.has_next
          col_index += 1
          
          cell = cell_it.next
          col_name = XLSX_COLUMNS[col_index][:name]
          puts "--col_index -> #{col_index} : name -> #{col_name}"
          
          case cell.get_cell_type
          when Cell::CELL_TYPE_NUMERIC
            _item.set_value_from_xml col_name, cell.get_numeric_cell_value

          when Cell::CELL_TYPE_STRING
            _item.set_value_from_xml col_name, cell.get_string_cell_value.strip
            
          end

        end

        #unless _item.valid?
          puts "==="
        
        _item.errors.clear
        _item.valid?
        
        p _item.errors.messages
        #else
        #  p _item
        #  puts "-- valid --"
        #end
        puts
        
      end
    else
      puts "Error to open openworkbook.xlsx file."
    end

    fis.close
  end

  def set_value_from_xml name, value
    puts "set_value --> "
    case name
    when :ref_model_uuid
      RefModel.where(model_name: value).limit(1).each{|row| self[name] = row.uuid }

    when :ref_unit_price_ref
      RefUnitPrice.where(unit_name: value).limit(1).each{|row| self[name] = row.uuid }

    else
      self[name] = value

    end
  end
end
