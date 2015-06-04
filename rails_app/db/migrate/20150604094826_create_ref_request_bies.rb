class CreateRefRequestBies < ActiveRecord::Migration
  def change
    create_table :ref_request_bies do |t|
      t.string  :display_name, null: false
      t.text    :remark
      t.string  :uuid, null: false, limit: 36

      t.integer :lock_version, null: false, default: 0
      t.datetime :deleted_at
      t.string  :created_by, null: false
      t.string  :updated_by, null: false

      t.timestamps
    end

    add_index :ref_request_bies, :display_name
    add_index :ref_request_bies, :uuid, unique: true
  end
end