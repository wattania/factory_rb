class CreateSysConfigs < ActiveRecord::Migration
  def change
    create_table :sys_configs do |t|
      t.string    :config_key, null: false
      t.decimal   :numeric_value, precision: 20, scale: 6
      t.text      :string_value

      t.integer   :lock_version, default: 0
      t.string    :created_by, null: false
      t.string    :updated_by, null: false
      t.datetime  :deleted_at

      t.timestamps null: false
    end

    add_index :sys_configs, :created_by
    add_index :sys_configs, :updated_by
  end
end
