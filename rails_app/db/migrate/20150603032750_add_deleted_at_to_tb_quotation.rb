class AddDeletedAtToTbQuotation < ActiveRecord::Migration
  def change
    add_column :tb_quotations, :deleted_at, :datetime
  end
end