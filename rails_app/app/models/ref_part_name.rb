class RefPartName < ActiveRecord::Base
  include FuncValidateHelper
  include FuncUpdateRecord
  include FuncModelUtils
  
  validate :v_duplicate_ref_display_name

  validates :display_name, presence: true
  before_validation :func_set_uuid, on: :create

end
