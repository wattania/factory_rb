class CreateRefRequestBies < ActiveRecord::Migration
  def change
    create_table :ref_request_bies do |t|

      t.timestamps null: false
    end
  end
end
