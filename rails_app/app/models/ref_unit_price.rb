class RefUnitPrice < ActiveRecord::Base
  include FuncValidateHelper
  include FuncUpdateRecord

  validates :unit_name, presence: true

  before_validation :func_set_uuid, on: :create

  validate :v_duplicate_unit_name

  def v_duplicate_unit_name
    return unless self.deleted_at
    if RefModel.select(1).where(deleted_at: nil).where(unit_name: self.unit_name).size > 0
      error[:unit_name] << "Unit Price Duplicate!"
    end
  end

  def self.dropdown
    ret = []
    where(deleted_at: nil).order(:unit_name).each{|row|
      ret.push({unit_name: row.unit_name, uuid: row.uuid})
    }
    ret
  end
end
