class CreateTbDieMolds < ActiveRecord::Migration
  def change
    create_table :tb_die_molds do |t|

      t.timestamps null: false
    end
  end
end
