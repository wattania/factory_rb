class CreateSysConfigByDates < ActiveRecord::Migration
  def change
    create_table :sys_config_by_dates do |t|
      t.date      :effective_date, null: false
      t.string    :config_key,    null: false
      t.decimal   :numeric_value, precision: 20, scale: 6
      t.text      :string_value

      t.integer   :lock_version,  default: 0, null: false
      t.string    :created_by,    null: false
      t.string    :updated_by,    null: false
      
      t.string    :uuid, null: false

      t.timestamps null: false
    end

    add_index :sys_config_by_dates, :created_by
    add_index :sys_config_by_dates, :updated_by
    add_index :sys_config_by_dates, :uuid, unique: true
  end
end
