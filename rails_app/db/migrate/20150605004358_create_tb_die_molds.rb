class CreateTbDieMolds < ActiveRecord::Migration
  def change
    create_table :tb_die_molds do |t|
      t.string :file_hash
      t.integer :row_no
      t.string :created_by, null: false
      t.string :updated_by, null: false

      t.string :invoice_no
      t.date   :invoice_date
      t.string :vendor
      t.string :by
      t.string :boi_name
      t.string :description
      t.string :dm_type

      t.string :ref_model_uuid
      t.string :model

      t.string :asset_ref
      t.integer :quantity
      t.string  :ref_unit_uuid
      t.string  :unit

      t.decimal :unit_price, precision: 20, scale: 2
      t.string  :currency
      t.string :ref_department_uuid
      t.string :department

      t.string :import_tr
      t.string :import_rtm
      t.date   :receive_date
      t.string :user_receive_by
      t.string :status
      t.string :install_delivery

      t.string :description_return0
      t.string :rtm_invoice0
      t.string :for0
      t.integer :return_qty0
      t.string :asset_doc0
      t.string :return_by_invoice0
      t.date   :send_date_oversea0
      t.string :vendor_return0
      t.string :remark_oversea0

      t.string :description_return1
      t.string :rtm_invoice1
      t.string :for1
      t.integer :return_qty1
      t.string :asset_doc1
      t.string :return_by_invoice1
      t.date   :send_date_oversea1
      t.string :vendor_return1
      t.string :remark_oversea1

      t.string :description_return2
      t.string :rtm_invoice2
      t.string :for2
      t.integer :return_qty2
      t.string :asset_doc2
      t.string :return_by_invoice2
      t.date   :send_date_oversea2
      t.string :vendor_return2
      t.string :remark_oversea2

      t.timestamps null: false
    end

    add_index :tb_die_molds, :created_by
    add_index :tb_die_molds, :updated_by
    add_index :tb_die_molds, :file_hash
  end
end
