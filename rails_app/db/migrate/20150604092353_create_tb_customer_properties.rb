class CreateTbCustomerProperties < ActiveRecord::Migration
  def change
    create_table :tb_customer_properties do |t|

      t.timestamps null: false
    end
  end
end
