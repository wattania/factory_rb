class CreateRefPartNames < ActiveRecord::Migration
  def change
    create_table :ref_part_names do |t|
      t.string  :part_name, null: false
      t.text    :remark
      t.string  :uuid, null: false, limit: 36

      t.integer :lock_version, null: false, default: 0
      t.datetime :deleted_at
      t.string  :created_by, null: false
      t.string  :updated_by, null: false

      t.timestamps
    end

    add_index :ref_part_names, :part_name
    add_index :ref_part_names, :uuid, unique: true
  end
end
