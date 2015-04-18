class LibModelUtils
  def self.customer_grid_view customer_id_field
    mt = WpUsermetum.arel_table
    mt_f = mt.alias 'first_name'
    mt_f_th = mt.alias 'first_name_th' 
    mt_l = mt.alias 'last_name'
    mt_l_th = mt.alias 'last_name_th'

    _ur = WpUser.arel_table
    ur = _ur.alias '_ur_'
    stmt = WpUser.user_info_stmt [ 'first_name', 'first_name_th', 'last_name', 'last_name_th' ], ur
    stmt.where(ur[:ID].eq customer_id_field)
    stmt.projections = [
      #Arel::Nodes::NamedFunction.new(:CONCAT_WS, [' - ', Arel.sql("CAST(`#{ur.name}`.`ID` AS CHAR) "), 
      Arel::Nodes::NamedFunction.new(:CONCAT_WS, [' - ', Arel::Nodes::NamedFunction.new(:CAST, [Arel.sql("`#{ur.name}`.`ID` AS CHAR")]),   
        Arel::Nodes::NamedFunction.new(:CONCAT_WS, [
          ' ', 
          Arel::Nodes::NamedFunction.new(:COALESCE, [
            Arel::Nodes::NamedFunction.new(:NULLIF, [mt_f_th[:meta_value], '']), mt_f[:meta_value]]),
          Arel::Nodes::NamedFunction.new(:COALESCE, [
            Arel::Nodes::NamedFunction.new(:NULLIF, [mt_l_th[:meta_value], '']), mt_l[:meta_value]]),
          ]) 
      ]).as('customer')
    ]
    #stmt.projections = [
    #  Arel::Nodes::NamedFunction.new(:CONCAT_WS, [' - ', mt_f_th[:meta_value]])
    #]
    stmt.where(ur[:ID].eq customer_id_field)
    stmt
  end

  def self.timestamp field
    #Arel::Nodes::NamedFunction.new('to_char', [field, 'DD/MM/YYYY HH24:MI:SS']) 
    Arel::Nodes::NamedFunction.new("DATE_FORMAT", [field, Arel::Nodes::Quoted.new('%d/%m/%Y %H:%i:%s')])
  end

  def self.timestamp_order field
    #Arel::Nodes::NamedFunction.new('to_char', [field, 'DD/MM/YYYY HH24:MI:SS']) 
    Arel::Nodes::NamedFunction.new(:DATE_FORMAT, [field, '%Y-%m-%d %H:%i:%s'])
  end

  def self.date field
    Arel::Nodes::NamedFunction.new(:DATE_FORMAT, [field, '%d/%m/%Y'])
  end

  def self.str_to_date field
    Arel::Nodes::NamedFunction.new(:STR_TO_DATE, [field, '%d/%m/%Y %H:%i:%s'])
  end

  def self.find_page_no_by_id tb, id, row_per_page 
    #SELECT * FROM (SELECT @row_number:=@row_number + 1 AS row_number, `tb_boxes`.* FROM tb_boxes inner join (SELECT @row_number:=0) AS t) a where id = 52
    aa = Arel::Table.new 'a'
    sub_stmt = tb.project([
      Arel.sql(" @row_number := @row_number + 1").as("row_number"), Arel.sql("`#{tb.name}`.*")
      ])
    .join(Arel.sql("(SELECT @row_number:=0)").as("a"))
    
    yield sub_stmt if block_given?

    tt = Arel::Table.new 'tt'
    stmt = tb.project(Arel.sql("(row_number DIV #{row_per_page}) + 1").as("page")).from("(#{sub_stmt.to_sql}) tt").where(tt[:id].eq id)
    ret = nil
    tb.engine.find_by_sql(stmt).each{|row|
      ret = row.page
    }
    ret
  end

  def self.project_stmt a_project_hash, a_other_array = []
    ret = []
    a_project_hash.each{|k, v|
      ret << v.clone.method('as').call(k)
    }
    ret + a_other_array
  end
end