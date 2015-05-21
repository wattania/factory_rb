class CreateRefCustomers < ActiveRecord::Migration
  def change
    create_table :ref_customers do |t|
      t.string  :cust_name, null: false
      t.text    :remark
      t.string  :uuid, null: false, limit: 36

      t.integer :lock_version, null: false, default: 0
      t.datetime :deleted_at
      t.string  :created_by, null: false
      t.string  :updated_by, null: false

      t.timestamps
    end

    add_index :ref_customers, :cust_name
    add_index :ref_customers, :uuid, unique: true

  end
end
