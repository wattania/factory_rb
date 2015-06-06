if defined?(JRUBY_VERSION)
  java_import Java::OrgApachePoiXssfUsermodel::XSSFWorkbook
  java_import Java::OrgApachePoiSsUsermodel::Cell
  java_import Java::OrgApachePoiSsUsermodel::Row
  java_import Java::OrgApachePoiXssfUsermodel::XSSFRow
  java_import Java::OrgApachePoiXssfUsermodel::XSSFSheet
  java_import Java::OrgApachePoiXssfUsermodel::XSSFWorkbook
end

class TbQuotationItem < ActiveRecord::Base
  #include ActiveModel::AttributeMethods
  #attribute_method_suffix '_ref_val'
  XLSX_CONFIG = {
    data_row_index: 1,
    columns: [
      {name: :item_code,           text: 'Item Code',       cell_type: :string, validates: [:no_blank] },
      {name: :ref_model_uuid,      text: 'Model',           cell_type: :string, validates: [:no_blank], ref_value: "RefModel" },
      {name: :sub_code,            text: 'Sub Code',        cell_type: :string, validates: [:no_blank] },
      {name: :customer_code,       text: 'Customer Code',   cell_type: :string, validates: [:no_blank] },
      {name: :part_name,           text: 'Part Name',       cell_type: :string, validates: [] },
      {name: :part_price,          text: 'Part Price',      cell_type: :float,  validates: [:no_blank]},
      {name: :package_price,       text: 'Package Price',   cell_type: :float,  validates: [:no_blank] },
      {name: :ref_unit_price_uuid, text: 'Unit Price',      cell_type: :string, validates: [:no_blank], ref_value: "RefUnitPrice" },
      {name: :po_reference,        text: 'PO reference',    cell_type: :string  },
      {name: :remark,              text: 'Remark',          cell_type: :string  }
    ]
  }

  include FuncValidateHelper
  include FuncUpdateRecord
  
  attr_accessor :ref_model_uuid_val, :ref_unit_price_uuid_val
  #validates :ref_model_uuid, presence: true 
  validates :file_hash, presence: true 

  #validate :v_ref_model_uuid
  #validate :v_ref_unit_price_ref
  validate :v_xls

  def v_xls
    v_helper_xls XLSX_CONFIG
  end

  def self.validate_xml file_upload, quotation_uuid, created_by, updated_by

    t = Tempfile.new ["#{Time.now.usec}", '.xlsx']
    t.binmode

    TbQuotationItem.where(quotation_uuid: quotation_uuid).delete_all
    ret = TbQuotationItem.v_validate_xml file_upload, t, XLSX_CONFIG do |type, item, row_data|
      case type
      when :new
        TbQuotationItem.new
        
      when :update
        item.quotation_uuid = quotation_uuid
        item.created_by = created_by
        item.updated_by = updated_by
      end
      
    end

    t.close
    t.unlink
    
    ret
  end

  def self.validate_file_name file_name

  end
end
