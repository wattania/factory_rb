class CreateFileUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
      t.binary  :file_data, null: false
      t.string  :file_hash, null: false
      t.decimal :file_size, null: false
      t.string  :content_type

      t.timestamps
    end

    add_index :file_uploads, :file_hash, unique: true

  end
end
