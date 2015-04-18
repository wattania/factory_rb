class CreateSysSeqs < ActiveRecord::Migration
  def change
    create_table :sys_seqs do |t|
      t.string  :seq_type, null: false
      t.date    :seq_date, null: false
      t.integer :last_number

      t.timestamps null: false
    end
  end
end
