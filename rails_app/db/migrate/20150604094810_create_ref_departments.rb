class CreateRefDepartments < ActiveRecord::Migration
  def change
    create_table :ref_departments do |t|

      t.timestamps null: false
    end
  end
end
