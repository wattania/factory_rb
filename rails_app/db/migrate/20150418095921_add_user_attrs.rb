class AddUserAttrs < ActiveRecord::Migration
  def change
    add_column :users, :uuid,          :string,  limit: 36, null: false
    add_column :users, :user_name,     :string,  null: false
    add_column :users, :first_name,    :string,  null: false
    add_column :users, :last_name,     :string
    add_column :users, :is_admin,      :boolean, default: false
    add_column :users, :timezone,      :string
    
    add_column :users, :lock_version,  :integer, default: 0
    add_column :users, :created_by,    :string
    add_column :users, :updated_by,    :string

    add_index :users, :uuid, unique: true
  end
end
