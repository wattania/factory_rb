class CreateTbQuotations < ActiveRecord::Migration
  def change
    create_table :tb_quotations do |t|
      t.string  :uuid, null: false, limit: 36
      t.string  :quotation_no
      t.string  :ref_customer_uuid, null: false, limit: 36
      t.date    :issue_date
      t.string  :ref_freight_term_uuid
      t.decimal :exchange_rate, precision: 20, scale: 4

      t.integer :lock_version, null: false, default: 0
      t.string  :created_by, null: false
      t.string  :updated_by, null: false

      t.timestamps
    end

    add_index :tb_quotations, :uuid, unique: true
    add_index :tb_quotations, :quotation_no
    add_index :tb_quotations, :ref_customer_uuid
    add_index :tb_quotations, :ref_freight_term_uuid
    add_index :tb_quotations, :created_by
    add_index :tb_quotations, :updated_by
  end
end
