class RefPartName < ActiveRecord::Base
  include FuncValidateHelper
  include FuncUpdateRecord

  validates :part_name, presence: true

  before_validation :func_set_uuid, on: :create

  validate :v_duplicate_part_name

  def v_duplicate_part_name
    return unless self.deleted_at
    if RefPartName.select(1).where(deleted_at: nil).where(part_name: self.part_name).size > 0
      error[:part_name] << "Part Name Duplicated!"
    end
  end

  def self.dropdown
    ret = []
    where(deleted_at: nil).order(:part_name).each{|row|
      ret.push({part_name: row.part_name, uuid: row.uuid})
    }
    ret
  end
end
