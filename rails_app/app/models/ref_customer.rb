class RefCustomer < ActiveRecord::Base
  include FuncValidateHelper
  include FuncUpdateRecord

  validates :cust_name, presence: true

  before_validation :func_set_uuid, on: :create

  validate :v_duplicate_cust_name

  def v_duplicate_cust_name
    return unless self.deleted_at
    if RefCustomer.select(1).where(deleted_at: nil).where(cust_name: self.cust_name).size > 0
      error[:cust_name] << "Customer Name Duplicate!"
    end
  end

  def self.dropdown
    ret = []
    where(deleted_at: nil).order(:cust_name).each{|row|
      ret.push({cust_name: row.cust_name, uuid: row.uuid})
    }
    ret
  end
end
