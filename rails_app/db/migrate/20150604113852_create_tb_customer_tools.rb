class CreateTbCustomerTools < ActiveRecord::Migration
  def change
    create_table :tb_customer_tools do |t|
      t.string  :customer_prop_uuid, null: false
      t.date    :tool_receive_date
      t.string  :invoice_no
      t.integer :receive_qty
      t.integer :row_no

      t.timestamps null: false
    end

    add_index :tb_customer_tools, :customer_prop_uuid
  end
end
