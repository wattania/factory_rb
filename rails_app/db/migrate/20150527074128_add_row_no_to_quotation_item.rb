class AddRowNoToQuotationItem < ActiveRecord::Migration
  def change
    add_column :tb_quotation_items, :row_no, :integer, null: false
  end
end
