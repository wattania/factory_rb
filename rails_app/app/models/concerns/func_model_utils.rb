module FuncModelUtils
  module FuncModelUtilsClassMethods
    def join_me stmt, me, field
      stmt.join(me).on(me[:uuid].eq field[(name.underscore + "_uuid").to_sym])
    end

    def left_join_me stmt, me, field
      stmt.join(me, Arel::Nodes::OuterJoin).on(me[:uuid].eq field[(name.underscore + "_uuid").to_sym])
    end

    def ref_get display_name, user_name = nil
      rf = where(display_name: display_name).first
      if rf.blank?
        rf = new
        rf.display_name = display_name
        rf.uuid = UUID.generate
        rf.created_by = user_name unless user_name.blank?
        rf.updated_by = user_name unless user_name.blank?
        rf.save!
      end
      rf
    end

    def ref_dropdown
      ret = []
      where(deleted_at: nil).order(:display_name).each{|row| 
        ret.push({display_name: row.display_name, uuid: row.uuid}) 
      }
      ret
    end

    def fn_get_effective_date_stmt a_common_field, a_date = Date.current, opts = {}#datefiel_sym = :effective_date
      me = arel_table
      me_a = me.alias 'a'

      datefiel_sym = :effective_date 
      datefiel_sym = opts[:datefield] unless opts[:datefield].blank?  

      max_effective_date_stmt = me.project([
        Arel::Nodes::NamedFunction.new("MAX", [me_a[datefiel_sym]])
        ])
      .from(me_a)
      .where(me_a[datefiel_sym].lteq a_date)

      max.where(me_a[:delete_flag].eq opts[:delete_flag]) unless opts[:delete_flag].nil?

      if a_common_field.is_a? Array
        a_common_field.each{|field|
          max_effective_date_stmt.where(me_a[field.to_s.to_sym].eq me[field.to_s.to_sym]) 
        }
      elsif a_common_field.is_a? Hash 
        a_common_field.each{|k, v|
          _field = k.to_s.to_sym
          max_effective_date_stmt.where(me_a[_field].eq me[k.to_s.to_sym]).where(me_a[_field].eq v) 

        }
      else
        common_sym = a_common_field.to_s.to_sym
        max_effective_date_stmt.where(me_a[common_sym].eq me[common_sym]) 
      end  
      

      stmt = me.project(Arel.star).where(
        me[datefiel_sym].eq Arel.sql "(#{max_effective_date_stmt.to_sql})"
      )#.take(1).order(me[:id])#5111->22 (อาจส่งผลกระทบ) 

      stmt.where(me_a[:delete_flag].eq opts[:delete_flag]) unless opts[:delete_flag].nil?

      if a_common_field.is_a? Hash
        a_common_field.each{|k, v|
          _field = k.to_s.to_sym
          stmt.where(me[_field].eq v)
        }
      end

      stmt 
    end
  end

  def self.included base
    base.extend FuncModelUtilsClassMethods
  end
end