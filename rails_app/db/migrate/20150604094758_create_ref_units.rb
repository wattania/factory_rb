class CreateRefUnits < ActiveRecord::Migration
  def change
    create_table :ref_units do |t|

      t.timestamps null: false
    end
  end
end
