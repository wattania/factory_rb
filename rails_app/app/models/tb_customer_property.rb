class TbCustomerProperty < ActiveRecord::Base
  include FuncExportExcel

  validates :document_no, uniqueness: true

  def self.index_list_stmt a_filter = {}, a_group_by_doc = false
    cp = TbCustomerProperty.arel_table
    rq = RefRequestBy.arel_table
    dp = RefDepartment.arel_table
    ut = RefUnit.arel_table
    tl = TbCustomerTool.arel_table
    ur = User.arel_table
 
    projects = {
      "record_id"     => cp[:id],
      "lock_version"  => cp[:lock_version],
      "document_no"   => { field: cp[:document_no], filter: :like },
      "uuid"          => cp[:uuid],
      "deleted_at"    => cp[:deleted_at],
      "description"   => { field: cp[:description], filter: :like },
      "request_by"    => { field: rq[:display_name], filter: :like },
      "department"    => { field: dp[:display_name], filter: :like },
      "request_qty"   => cp[:request_qty],
      "unit"          => { field: ut[:display_name], filter: :like },
      "cmd_issue_date"=> cp[:cmd_issue_date],
      "require_date"  => cp[:require_date],
      "status"        => { field: cp[:status], filter: :like },
      "tool_receive_date" => tl[:tool_receive_date],
      "invoice_no"    => { field: tl[:invoice_no], filter: :like },
      "receive_qty"   => tl[:receive_qty],
      "balance_qty"   => Arel.sql("(COALESCE(#{cp.table_name}.request_qty, 0) - (
        SELECT SUM(COALESCE(aa.receive_qty, 0))
        FROM #{tl.table_name} aa 
        WHERE aa.customer_prop_uuid = #{cp.table_name}.uuid
      )) "),
      "remark"        => {field: cp[:remark], filter: :like },
      "doc_approved_file_name" => { field: cp[:doc_approved_file_name], filter: :like }
    }

    stmt = cp.project(XModelUtils.project_stmt projects)
      .join(ur).on(ur[:uuid].eq(cp[:created_by]))
      .join(tl, Arel::Nodes::OuterJoin).on(tl[:customer_prop_uuid].eq(cp[:uuid]))
      .order([cp[:document_no], Arel.sql("row_no NULLS LAST")])

    RefRequestBy.left_join_me stmt, rq, cp
    RefDepartment.left_join_me stmt, dp, cp
    RefUnit.left_join_me stmt, ut, cp

    XModelUtils.filter_stmt stmt, a_filter, projects do |k, v|
      case k
      when 'tool_receive_date_from'
        tl[:tool_receive_date].gteq v 
      when 'tool_receive_date_to'
        tl[:tool_receive_date].lteq v 
      when 'cmd_issue_date_from'
        cp[:cmd_issue_date].gteq v 
      when 'cmd_issue_date_to'
        cp[:cmd_issue_date].lteq v 
      when 'require_date_from'
        cp[:require_date].gteq v 
      when 'require_date_to'
        cp[:require_date].lteq v
      when 'deleted'
        if v == '0'
          cp[:deleted_at].eq nil
        elsif v == '1'
          cp[:deleted_at].not_eq nil
        end
      end
    end
    
    if a_group_by_doc

      tool_receive_date_stmt = tl.project(tl[:tool_receive_date]).where(tl[:customer_prop_uuid].eq cp[:uuid]).order(tl[:tool_receive_date]).take(1)
      
      projects['tool_receive_date'] = Arel.sql "(" + tool_receive_date_stmt.to_sql + ")"
 
      invoice_stmt = tl.project(tl[:invoice_no]).where(tl[:customer_prop_uuid].eq cp[:uuid]).order(tl[:invoice_no])
      invoice_stmt.distinct
      invoice_stmt = Arel::Nodes::NamedFunction.new("ARRAY", [Arel.sql(invoice_stmt.to_sql)])
      projects['invoice_no'] = Arel::Nodes::NamedFunction.new('ARRAY_TO_STRING', [Arel.sql(invoice_stmt.to_sql), Arel::Nodes::Quoted.new(', ')])

      projects["receive_qty"] = Arel.sql "(
        SELECT SUM(COALESCE(aa.receive_qty, 0))
        FROM #{tl.table_name} aa 
        WHERE aa.customer_prop_uuid = #{cp.table_name}.uuid
        )"

      stmt = cp.project(XModelUtils.project_stmt projects).where(cp[:document_no].in Arel.sql("(
        SELECT distinct(document_no) FROM (#{stmt.to_sql}) AA )

      ")).join(ur).on(ur[:uuid].eq(cp[:created_by]))
        .order(cp[:document_no])

      RefRequestBy.left_join_me stmt, rq, cp
      RefDepartment.left_join_me stmt, dp, cp
      RefUnit.left_join_me stmt, ut, cp

      stmt

    else
      stmt
    end
  end

  EXPORT_ALL_DETAILS = {
    "delete"        => { title: "Delete",         type: :string },
    "document_no"   => { title: "Document No.",   type: :string },
    "description"   => { title: "Description",    type: :string },
    "request_by"    => { title: "Request By",     type: :string },
    "department"    => { title: 'Department',     type: :string },
    "request_qty"   => { title: "Request Qty"                   },
    "unit"          => { title: "Unit",           type: :string   },
    "cmd_issue_date"=> { title: "CMD Issue Date", type: :string },
    "require_date"  => { title: "Require Date",          type: :string },
    "status"        => { title: "Status",         type: :string },
    "tool_receive_date" => { title: "Tool Receive Date",  type: :string},
    "invoice_no"      => { title: "Invoice N0.",      type: :string },
    "receive_qty"     => { title: "Receive Qty"      },
    "remark"          => { title: "Remark",       type: :string  },
    "doc_approved_file_name"   => { title: "Doc.Approved", type: :string     },
    
  }

  def self.export_all filter = {}
    stmt = index_list_stmt filter
    conn = ActiveRecord::Base.connection
    datas = []
    conn.execute(stmt.to_sql).each{|data|
      unless data["deleted_at"].blank?
        data["delete"] = "Delete" 
      end
      datas.push data
    }

    __export_excel datas, EXPORT_ALL_DETAILS, "Cust.Properties" do |func, data|
      case func
      when :header_style
        Axlsx::STYLE_THIN_BORDER
      end
    end
  end
end
