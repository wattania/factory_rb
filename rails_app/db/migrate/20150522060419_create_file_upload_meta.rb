class CreateFileUploadMeta < ActiveRecord::Migration
  def change
    create_table :file_upload_meta do |t|
      t.string  :file_name, null: false
      t.string  :file_hash, null: false
      t.string  :uploaded_by

      t.timestamps null: false
    end

    add_index :file_upload_meta, :file_name
    add_index :file_upload_meta, :file_hash
  end
end
