#encoding: UTF-8
module FuncValidateHelper
  def func_set_uuid
    self.uuid = UUID.generate if self.uuid.blank?
  end
end