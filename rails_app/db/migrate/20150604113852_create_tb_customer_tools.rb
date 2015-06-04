class CreateTbCustomerTools < ActiveRecord::Migration
  def change
    create_table :tb_customer_tools do |t|

      t.timestamps null: false
    end
  end
end
