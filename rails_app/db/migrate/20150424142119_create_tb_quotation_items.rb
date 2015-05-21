class CreateTbQuotationItems < ActiveRecord::Migration
  def change
    create_table :tb_quotation_items do |t|
      t.string  :quotation_uuid,      null: false
      t.string  :item_code
      t.string  :ref_model_uuid,      null: false
      t.string  :sub_code
      t.string  :customer_code
      t.string  :part_name
      t.string  :ref_part_uuid,       null: false
      t.decimal :part_price,          precision: 20, scale: 2
      t.decimal :package_price,       precision: 20, scale: 2
      t.string  :ref_unit_price_ref,  null: false
      t.string  :po_reference,        limit: 400
      t.string  :remark,              limit: 400
      t.string  :file_hash,           null: false

      t.string  :created_by,          null: false
      t.string  :updated_by,          null: false

      t.timestamps
    end

    add_index :tb_quotation_items, :quotation_uuid, unique: true
    add_index :tb_quotation_items, :ref_model_uuid
    add_index :tb_quotation_items, :ref_unit_price_ref
    add_index :tb_quotation_items, :file_hash

    add_index :tb_quotation_items, :created_by
    add_index :tb_quotation_items, :updated_by
  end
end
