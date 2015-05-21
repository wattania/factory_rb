class CreateTbQuotationCalculationFiles < ActiveRecord::Migration
  def change
    create_table :tb_quotation_calculation_files do |t|
      t.string  :tb_quotation_uuid, null: false

      t.string  :file_hash, null: false
      t.string  :file_name, null: false

      t.string  :created_by, null: false
      t.string  :updated_by, null: false

      t.timestamps
    end

    add_index :tb_quotation_calculation_files, :file_hash, unique: true
    add_index :tb_quotation_calculation_files, :file_name

    add_index :tb_quotation_calculation_files, :created_by
    add_index :tb_quotation_calculation_files, :updated_by
  end
end
