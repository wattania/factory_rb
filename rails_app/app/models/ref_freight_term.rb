class RefFreightTerm < ActiveRecord::Base
  include FuncValidateHelper
  include FuncUpdateRecord

  validates :freight_term, presence: true

  before_validation :func_set_uuid, on: :create

  validate :v_duplicate_freight_term

  def v_duplicate_freight_term
    return unless self.deleted_at
    if RefFreightTerm.select(1).where(deleted_at: nil).where(freight_term: self.freight_term).size > 0
      error[:freight_term] << "Freight Term Duplicate!"
    end
  end

  def self.dropdown
    ret = []
    where(deleted_at: nil).order(:freight_term).each{|row|
      ret.push({freight_term: row.freight_term, uuid: row.uuid})
    }
    ret
  end
end
