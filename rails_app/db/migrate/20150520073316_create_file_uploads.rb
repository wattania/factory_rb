class CreateFileUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
      t.string  :file_name, null: false
      t.string  :file_hash, null: false
      t.decimal :file_size
      t.string  :uploaded_by

      t.timestamps
    end

    add_index :file_uploads, :file_name
    add_index :file_uploads, :file_hash
  end
end
