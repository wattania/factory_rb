class CreateSysDummies < ActiveRecord::Migration
  def change
    create_table :sys_dummies do |t|
      t.string :dummy
      t.timestamps null: false
    end
  end
end
