#encoding: UTF-8
module FuncValidateHelper
  def func_set_uuid
    self.uuid = UUID.generate if self.uuid.blank?
  end

  def v_duplicate_ref_display_name
    return if self.deleted_at
    if self.class.select(1).where(deleted_at: nil).where(display_name: self.display_name).size > 0
      errors[:display_name] << "Display Name Duplicate!"
    end
  end
end