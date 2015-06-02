class ChangePriceToPrecisionFour < ActiveRecord::Migration
  def up
    change_column :tb_quotation_items, :part_price, :decimal, precision: 20, scale: 4
    change_column :tb_quotation_items, :package_price, :decimal, precision: 20, scale: 4
  end

  def down
    change_column :tb_quotation_items, :part_price, :decimal, precision: 20, scale: 4
    change_column :tb_quotation_items, :package_price, :decimal, precision: 20, scale: 4
  end
end