#encoding: UTF-8
module FuncUpdateRecord
  def copy_attrs to_model, ignore_field_sym = [], force = false
    self.attributes.each{|k, v|
      key = k.to_s.to_sym
      unless ignore_field_sym.include? key
        if force
          to_model[key] = v
        else
          to_model[key] = v unless to_model.method(key.to_s + '_changed?').call#if to_model[key].blank?
        end
      end
    }
  end

  def fn_create_record_data params, excepts = []
    fn_update_record_data params, excepts
  end

  def fn_update_record_data params, excepts = [] 
    columns_hash = self.class.columns_hash

    attr_lst = self.attributes.keys
    (params || {}).each{|k, v|
      next if (v.is_a? Array) || (v.is_a? Hash)
      next if excepts.include? k.to_sym

      case k
      when 'lock_version'
        self[k.to_sym] = v unless v.blank?
      when 'id'
      else 
        if attr_lst.include? k
          if v.is_a? Array
            value = v.first if v.uniq.size == 1
          else
            value = v
          end

          prop = columns_hash[k]
          unless prop.nil? 
            if prop.type.to_s == "boolean"  
              unless value.is_a? TrueClass or value.is_a? FalseClass 
                if ['yes', 'Yes', 'YES', 'true', 'True', 'TRUE'].include? value
                  value = true 
                else
                  value = false
                end
              end
            end
          end 

          self[k.to_sym] = value
        end 
      end 
    }
  end

  def fn_update_has_many_from_grid a_has_many_name, params, user, program, &new_block
    
    members = self.method(a_has_many_name).call reload: true
     
    data_list   = params['data']     || []
    delete_list = params['deleted']  || []
 
    members.each{|m| m.delete_flag = true} if data_list.size <= 0 
    
    data_list.each{|data|
      case data["grid_action"]
      when 'new'
        member = self.method(a_has_many_name).call.build

        new_block.call :new, member

        member.fn_create_record_data data
        member.create_user       = user
        member.create_date_time  = DateTime.current
        member.edit_user         = user
        member.edit_date_time    = DateTime.current
        member.edit_program      = program
 
        self.updated_at = DateTime.current if member.changed?
 
      when 'edit'
        unless data['id'].blank?
          members.each{|member|
            if member.id.to_s == data['id'].to_s
              new_block.call :edit, member
              
              member.edit_user    = user
              member.edit_program = program
              member.fn_update_record_data data
 
              self.updated_at = DateTime.current if member.changed?
            end
          }
        end
       
      end

    }
    if delete_list.size > 0
      delete_ids = []
      delete_list.each{|data|
        delete_ids << data['id'].to_s unless data['id'].to_s.blank?
      }

      members.each{|member|
        member.delete_flag = true if delete_ids.include? member.id.to_s
      }
    end
  end

end