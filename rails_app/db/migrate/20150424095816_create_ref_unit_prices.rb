class CreateRefUnitPrices < ActiveRecord::Migration
  def change
    create_table :ref_unit_prices do |t|
      t.string  :unit_name, null: false
      t.text    :remark
      t.string  :uuid, null: false, limit: 36

      t.integer :lock_version, null: false, default: 0
      t.datetime :deleted_at
      t.string  :created_by, null: false
      t.string  :updated_by, null: false

      t.timestamps
    end

    add_index :ref_unit_prices, :unit_name
    add_index :ref_unit_prices, :uuid, unique: true
  end
end
