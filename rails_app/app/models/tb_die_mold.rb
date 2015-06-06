class TbDieMold < ActiveRecord::Base
  include FuncValidateHelper
  include FuncUpdateRecord
  include FuncExportExcel

XLSX_CONFIG = {
  data_row_index: 1,
  col_data: 1,
  columns: [
    {name: :invoice_no,         text: "Invoice No."  },
    {name: :invoice_date,       text: "Invoice Date"  },
    {name: :vendor,             text: 'Vendor' },
    {name: :by,                 text: 'By' },
    {name: :boi_name,           text: 'BOI Name'},
    {name: :description,        text: '7_Description.Description'},
    {name: :dm_type,               text: 'Type'},
    {name: :model,              text: 'Model'},
    {name: :asset_ref,          text: 'ASSET/Ref'},
    {name: :quantity,           text: 'Quantity'},
    {name: :unit,               text: 'Unit'},
    {name: :unit_price,         text: 'Unit Price'},
    {name: :currency,           text: 'Currency'},
    {name: :department,         text: 'Department'},
    {name: :import_tr,          text: 'Import TR'},
    {name: :import_rtm,         text: 'Import RTM'},
    {name: :receive_date,       text: 'Receive Date'},
    {name: :user_receive_by,    text: 'User Receive By'},
    {name: :status,             text: 'Status'},
    {name: :install_delivery,   text: 'Install Delivery'},

    {name: :description_return0, text: 'Description Return'},
    {name: :rtm_invoice0,        text: 'RTM Return'},
    {name: :for0,                text: 'For'},
    {name: :return_qty0,         text: 'Return Qty'},
    {name: :asset_doc0,          text: 'Asset Doc'},
    {name: :return_by_invoice0,  text: 'Return by invoice'},
    {name: :send_date_oversea0,  text: 'Send data over sea'},
    {name: :vendor_return0,      text: 'Vendor Return'},
    {name: :remark_oversea0,     text: 'Remark over sea'},

    {name: :description_return1, text: 'Description Return1'},
    {name: :rtm_invoice1,        text: 'RTM Return1'},
    {name: :for1,                text: 'For1'},
    {name: :return_qty1,         text: 'Return Qty1'},
    {name: :asset_doc1,          text: 'Asset Doc1'},
    {name: :return_by_invoice1,  text: 'Return by invoice1'},
    {name: :send_date_oversea1,  text: 'Send data over sea1'},
    {name: :vendor_return1,      text: 'Vendor Return1'},
    {name: :remark_oversea1,     text: 'Remark over sea1'},

    {name: :description_return2, text: 'Description Return2'},
    {name: :rtm_invoice2,        text: 'RTM Return2'},
    {name: :for2,                text: 'For2'},
    {name: :return_qty2,         text: 'Return Qty2'},
    {name: :asset_doc2,          text: 'Asset Doc2'},
    {name: :return_by_invoice2,  text: 'Return by invoice2'},
    {name: :send_date_oversea2,  text: 'Send data over sea2'},
    {name: :vendor_return2,      text: 'Vendor Return2'},
    {name: :remark_oversea2,     text: 'Remark over sea2'}
  ]}

  def self.validate_xml file_upload, user

    t = Tempfile.new ["#{Time.now.usec}", '.xlsx']
    t.binmode

    where(file_hash: file_upload.file_hash).delete_all
    ret = v_validate_xml file_upload, t, XLSX_CONFIG do |type, item, row_data|
      case type
      when :new
        TbDieMold.new
        
      when :update
        item.created_by = user.uuid
        item.updated_by = user.uuid
      end
      
    end

    t.close
    t.unlink
    
    ret
  end

  def self.index_list_stmt a_filter = {}
    dm = TbDieMold.arel_table
    
    ur = User.arel_table
    

    projects = {
      "record_id"     => dm[:id], 
      "file_hash"     => dm[:file_hash],
      "invoice_no"    => {field: dm[:invoice_no], filter: :like },
      "invoice_date"  => dm[:invoice_date],
      "vendor"        => {field: dm[:vendor], filter: :like },
      "by"            => {field: dm[:by], filter: :like },
      "boi_name"      => {field: dm[:boi_name], filter: :like },
      "description"   => {field: dm[:description], filter: :like },
      "dm_type"          => {field: dm[:dm_type], filter: :like },
      "model"         => {field: dm[:model], filter: :like },
      "asset_ref"     => {field: dm[:asset_ref], filter: :like },
      "quantity"      => dm[:quantity],
      "unit"          => {field: dm[:unit], filter: :like },
      "unit_price"    => dm[:unit_price],
      "currency"      => {field: dm[:currency], filter: :like },
      "department"    => {field: dm[:department], filter: :like },
      "import_tr"     => {field: dm[:import_tr], filter: :like },
      "import_rtm"    => {field: dm[:import_rtm], filter: :like },
      "receive_date"  => dm[:receive_date],
      "user_receive_by"     => {field: dm[:user_receive_by], filter: :like },
      "status"              => {field: dm[:status], filter: :like },
      "install_delivery"    => {field: dm[:install_delivery], filter: :like },

      "description_return0" => {field: dm[:description_return0], filter: :like },
      "rtm_invoice0"        => {field: dm[:rtm_invoice0], filter: :like },
      "for0"                => {field: dm[:for0], filter: :like },
      "return_qty0"         => dm[:return_qty0],
      "asset_doc0"          => {field: dm[:asset_doc0], filter: :like },
      "return_by_invoice0"  => {field: dm[:return_by_invoice0], filter: :like },
      "send_date_oversea0"  => dm[:send_date_oversea0],
      "vendor_return0"      => {field: dm[:vendor_return0], filter: :like },
      "remark_oversea0"     => {field: dm[:remark_oversea0], filter: :like },

      "description_return1" => {field: dm[:description_return1], filter: :like },
      "rtm_invoice1"        => {field: dm[:rtm_invoice1], filter: :like },
      "for1"                => {field: dm[:for1], filter: :like },
      "return_qty1"         => dm[:return_qty1],
      "asset_doc1"          => {field: dm[:asset_doc1], filter: :like },
      "return_by_invoice1"  => {field: dm[:return_by_invoice1], filter: :like },
      "send_date_oversea1"  => dm[:send_date_oversea1],
      "vendor_return1"      => {field: dm[:vendor_return1], filter: :like },
      "remark_oversea1"     => {field: dm[:remark_oversea1], filter: :like },

      "description_return2" => {field: dm[:description_return2], filter: :like },
      "rtm_invoice2"        => {field: dm[:rtm_invoice2], filter: :like },
      "for2"                => {field: dm[:for2], filter: :like },
      "return_qty2"         => dm[:return_qty2],
      "asset_doc2"          => {field: dm[:asset_doc2], filter: :like },
      "return_by_invoice2"  => {field: dm[:return_by_invoice2], filter: :like },
      "send_date_oversea2"  => dm[:send_date_oversea2],
      "vendor_return2"      => {field: dm[:vendor_return2], filter: :like },
      "remark_oversea2"     => {field: dm[:remark_oversea2], filter: :like }
    }

    stmt = dm.project(XModelUtils.project_stmt projects)
      .join(ur).on(ur[:uuid].eq(dm[:created_by]))
      .order([dm[:created_by].desc, dm[:file_hash], dm[:row_no]])
 
    XModelUtils.filter_stmt stmt, a_filter, projects do |k, v|
      case k
      when 'invoice_date_from'
        dm[:invoice_date].gteq v 
      when 'invoice_date_to'
        dm[:invoice_date].lteq v 

      when 'receive_date_from'
        dm[:receive_date].gteq v 
      when 'receive_date_to'
        dm[:receive_date].lteq v 

      when 'send_date_oversea0_from'
        dm[:send_date_oversea0].gteq v
      when 'send_date_oversea0_to'
        dm[:send_date_oversea0].lteq v

      when 'send_date_oversea1_from'
        dm[:send_date_oversea1].gteq v
      when 'send_date_oversea1_to'
        dm[:send_date_oversea1].lteq v

      when 'send_date_oversea2_from'
        dm[:send_date_oversea2].gteq v
      when 'send_date_oversea2_to'
        dm[:send_date_oversea2].lteq v
      end
    end
  end

  EXPORT_ALL_DETAILS = {
    "invoice_no"         => { title: "Invoice No."  },
    "invoice_date"       => { title: "Invoice Date"  },
    "vendor"             => { title: "Vendor" },
    "by"                 => { title: "By" },
    "boi_name"           => { title: "BOI Name"},
    "description"        => { title: "7_Description.Description"},
    "dm_type"            => { title: "Type"},
    "model"              => { title: "Model"},
    "asset_ref"          => { title: "ASSET/Ref"},
    "quantity"           => { title: "Quantity"},
    "unit"               => { title: "Unit"},
    "unit_price"         => { title: "Unit Price"},
    "currency"           => { title: "Currency"},
    "department"         => { title: "Department"},
    "import_tr"          => { title: "Import TR"},
    "import_rtm"         => { title: "Import RTM"},
    "receive_date"       => { title: "Receive Date"},
    "user_receive_by"    => { title: "User Receive By"},
    "status"             => { title: "Status"},
    "install_delivery"   => { title: "Install Delivery"},

    "description_return0" => { title: "Description Return"},
    "rtm_invoice0"        => { title: "RTM Return"},
    "for0"                => { title: "For"},
    "return_qty0"         => { title: "Return Qty"},
    "asset_doc0"          => { title: "Asset Doc"},
    "return_by_invoice0"  => { title: "Return by invoice"},
    "send_date_oversea0"  => { title: "Send data over sea"},
    "vendor_return0"      => { title: "Vendor Return"},
    "remark_oversea0"     => { title: "Remark over sea"},

    "description_return1" => { title: "Description Return1"},
    "rtm_invoice1"        => { title: "RTM Return1"},
    "for1"                => { title: "For1"},
    "return_qty1"         => { title: "Return Qty1"},
    "asset_doc1"          => { title: "Asset Doc1"},
    "return_by_invoice1"  => { title: "Return by invoice1"},
    "send_date_oversea1"  => { title: "Send data over sea1"},
    "vendor_return1"      => { title: "Vendor Return1"},
    "remark_oversea1"     => { title: "Remark over sea1"},

    "description_return2" => { title: "Description Return2"},
    "rtm_invoice2"        => { title: "RTM Return2"},
    "for2"                => { title: "For2"},
    "return_qty2"         => { title: "Return Qty2"},
    "asset_doc2"          => { title: "Asset Doc2"},
    "return_by_invoice2"  => { title: "Return by invoice2"},
    "send_date_oversea2"  => { title: "Send data over sea2"},
    "vendor_return2"      => { title: "Vendor Return2"},
    "remark_oversea2"     => { title: "Remark over sea2"}
  }

  def self.export_all filter = {}
    stmt = index_list_stmt filter
    conn = ActiveRecord::Base.connection
    datas = []
    conn.execute(stmt.to_sql).each{|data|
      datas.push data
    }

    __export_excel datas, EXPORT_ALL_DETAILS, "DieMold" do |func, data|
      case func
      when :header_style
        Axlsx::STYLE_THIN_BORDER
      end
    end
  end
end
