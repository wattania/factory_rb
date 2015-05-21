class CreateRefFreightTerms < ActiveRecord::Migration
  def change
    create_table :ref_freight_terms do |t|
      t.string  :freight_term, null: false
      t.text    :remark
      t.string  :uuid, null: false, limit: 36

      t.integer :lock_version, null: false, default: 0
      t.datetime :deleted_at
      t.string  :created_by, null: false
      t.string  :updated_by, null: false

      t.timestamps
    end

    add_index :ref_freight_terms, :freight_term
    add_index :ref_freight_terms, :uuid, unique: true
  end
end
