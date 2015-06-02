class FixPartNameFromRefToText < ActiveRecord::Migration
  def up
    remove_column :tb_quotation_items, :ref_part_name_uuid
    add_column :tb_quotation_items, :part_name, :string
    add_index :tb_quotation_items, :part_name
  end

  def down
    remove_column :tb_quotation_items, :part_name
    add_column :tb_quotation_items, :ref_part_name_uuid, :string, null: false
    add_index :tb_quotation_items, :ref_part_name_uuid
  end
end