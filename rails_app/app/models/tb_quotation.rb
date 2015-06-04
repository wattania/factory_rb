class TbQuotation < ActiveRecord::Base
  validates :quotation_no, uniqueness: true
  include FuncExportExcel
  
  def self.item_group_stmt field
    it = TbQuotationItem.arel_table
    qa = TbQuotation.arel_table
    stmt = it.project(field).where(it[:quotation_uuid].eq qa[:uuid]).order(field)
    stmt.distinct
    
    yield stmt if block_given?

    stmt = Arel::Nodes::NamedFunction.new("ARRAY", [Arel.sql(stmt.to_sql)])
  end

  def self.item_total_stmt field 
    it = TbQuotationItem.arel_table
    qa = TbQuotation.arel_table
    it.project(Arel::Nodes::NamedFunction.new("SUM", [field])).where(it[:quotation_uuid].eq qa[:uuid])
  end

  def self.index_list_stmt a_filter = {}, a_group_by_qaotation = false
    qa = TbQuotation.arel_table
    ct = RefCustomer.arel_table
    ur = User.arel_table
    ft = RefFreightTerm.arel_table
    it = TbQuotationItem.arel_table
    ut = RefUnitPrice.arel_table
    md = RefModel.arel_table

    projects = {
      "record_id"     => qa[:id],
      "uuid"          => qa[:uuid],
      "deleted_at"    => qa[:deleted_at],
      "quotation_no"  => {field: qa[:quotation_no], filter: :like },
      "customer"      => {field: ct[:display_name], filter: :like },
      "created_by"    => { field: XModelUtils.desc(ur[:first_name], ur[:last_name], ' '), filter: :like },
      "issue_date"    => qa[:issue_date],
      "freight_term"  => { field: ft[:display_name], filter: :like },
      "exchange_rate" => qa[:exchange_rate],
      "item_code"     => { field: it[:item_code], filter: :like },
      "sub_code"      => { field: it[:sub_code], filter: :like },
      "part_price"    => it[:part_price],
      "po_reference"  => { field: it[:po_reference], filter: :like },
      "remark"        => { field: it[:remark], filter: :like },
      "package_price" => it[:package_price],
      "total_price"   => Arel.sql("(COALESCE(#{it.table_name}.part_price, 0) + COALESCE(#{it.table_name}.package_price, 0)) "),
      "customer_code" => { field: it[:customer_code], filter: :like },
      "unit_price"    => { field: ut[:display_name], filter: :like },
      "part_name"     => { field: it[:part_name], filter: :like },
      "model"         => { field: md[:display_name], filter: :like },
      "total_approve_file"    => Arel.sql("(SELECT COUNT(*) FROM #{TbQuotationApproveFile.table_name} WHERE tb_quotation_uuid = #{TbQuotation.table_name}.uuid)"),
      "total_calculate_file"  => Arel.sql("(SELECT COUNT(*) FROM #{TbQuotationCalculationFile.table_name} WHERE tb_quotation_uuid = #{TbQuotation.table_name}.uuid)"),
    }

    stmt = qa.project(XModelUtils.project_stmt projects)
      .join(ur).on(ur[:uuid].eq(qa[:created_by]))
      .join(it, Arel::Nodes::OuterJoin).on(it[:quotation_uuid].eq(qa[:uuid]))
      .order(qa[:quotation_no])


    RefCustomer.left_join_me stmt, ct, qa
    RefFreightTerm.left_join_me stmt, ft, qa

    RefModel.left_join_me stmt, md, it
    RefUnitPrice.left_join_me stmt, ut, it
 
    XModelUtils.filter_stmt stmt, a_filter, projects do |k, v|
      case k
      when 'issue_date_from'
        qa[:issue_date].gteq v 
      when 'issue_date_to'
        qa[:issue_date].lteq v 
      when 'deleted'
        if v == '0'
          qa[:deleted_at].eq nil
        elsif v == '1'
          qa[:deleted_at].not_eq nil
        end
      end
    end
    
    if a_group_by_qaotation
      ## unit price
      all_unit_price_stmt = item_group_stmt(ut[:display_name]){|st| RefUnitPrice.left_join_me st, ut, it }
      all_item_code = item_group_stmt(it[:item_code])
      all_sub_code  = item_group_stmt(it[:sub_code])
      all_cust_code = item_group_stmt(it[:customer_code])
      all_model     = item_group_stmt(md[:display_name]){|st| RefModel.left_join_me st, md, it }
      all_part_name = item_group_stmt(it[:part_name])

      projects = {
        "record_id"     => qa[:id],
        "uuid"          => qa[:uuid],
        "quotation_no"  => {field: qa[:quotation_no], filter: :like },
        "customer"      => {field: ct[:display_name], filter: :like },
        "created_by"    => { field: XModelUtils.desc(ur[:first_name], ur[:last_name], ' '), filter: :like },
        "issue_date"    => qa[:issue_date],
        "freight_term"  => ft[:display_name],
        "exchange_rate" => qa[:exchange_rate],
        "deleted_at"    => qa[:deleted_at],
        "package_price" => item_total_stmt(it[:package_price]),
        "part_price"    => item_total_stmt(it[:part_price]),
        "item_code"     => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_item_code.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "model"         => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_model.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "sub_code"      => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_sub_code.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "part_name"     => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_part_name.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "customer_code" => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_cust_code.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "unit_price"    => Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(all_unit_price_stmt.to_sql), Arel::Nodes::Quoted.new(', ')]),
        "total_approve_file"    => Arel.sql("(SELECT COUNT(*) FROM #{TbQuotationApproveFile.table_name} WHERE tb_quotation_uuid = #{TbQuotation.table_name}.uuid)"),
        "total_calculate_file"  => Arel.sql("(SELECT COUNT(*) FROM #{TbQuotationCalculationFile.table_name} WHERE tb_quotation_uuid = #{TbQuotation.table_name}.uuid)"),
      }

      stmt = qa.project(XModelUtils.project_stmt projects).where(qa[:quotation_no].in Arel.sql("(
        SELECT distinct(quotation_no) FROM (#{stmt.to_sql}) AA )

      ")).join(ur).on(ur[:uuid].eq(qa[:created_by]))
        .order(qa[:quotation_no])

      RefCustomer.left_join_me stmt, ct, qa
      RefFreightTerm.left_join_me stmt, ft, qa

      stmt

    else
      stmt
    end
  end

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
        
        sheet.add_row row, :types => [nil, nil, :string, :string, :string]
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

  EXPORT_ALL_DETAILS = {
    "delete"        => { title: "Delete",         type: :string },
    "quotation_no"  => { title: "Quotation No.",  type: :string },
    "customer"      => { title: "Customer",       type: :string },
    "created_by"    => { title: "Create Person",  type: :string },
    "issue_date"    => { title: 'Issue Date',     type: :string },
    "freight_term"  => { title: "Freight Term",   type: :string },
    "exchange_rate" => { title: "Exchange Rate"   },
    "item_code"     => { title: "Item Code",      type: :string },
    "model"         => { title: "Model",          type: :string },
    "sub_code"      => { title: "Sub Code",       type: :string },
    "customer_code" => { title: "Customer Code",  type: :string},
    "part_name"     => { title: "Part Name",      type: :string },
    "part_price"    => { title: "Part Price"      },
    "package_price" => { title: "Package Price"   },
    "total_price"   => { title: "Total Price"     },
    "unit_price"    => { title: "Unit Price"      },
    "po_reference"  => { title: "PO Reference",   type: :string },
    "remark"        => { title: "Remark",         type: :string }
  }



  def self.export_all filter = {}
    stmt = TbQuotation.index_list_stmt filter
    conn = ActiveRecord::Base.connection
    datas = []
    conn.execute(stmt.to_sql).each{|data|
      unless data["deleted_at"].blank?
        data["delete"] = "Delete" 
      end
      datas.push data
    }

    TbQuotation.__export_excel datas, EXPORT_ALL_DETAILS, "Quotations" do |func, data|
      case func
      when :header_style
        Axlsx::STYLE_THIN_BORDER
      end
    end
  end
end
