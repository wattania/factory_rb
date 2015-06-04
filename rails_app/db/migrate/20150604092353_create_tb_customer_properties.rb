class CreateTbCustomerProperties < ActiveRecord::Migration
  def change
    create_table :tb_customer_properties do |t|
      t.string  :document_no, null: false
      t.string  :uuid, null: false
      t.text    :description
      t.string  :ref_request_by_uuid
      t.string  :ref_department_uuid

      t.integer :request_qty
      t.string  :ref_unit_uuid
      t.date    :cmd_issue_date
      t.date    :require_date
      t.string  :status
      t.string  :doc_approved_file_name
      t.string  :doc_approved_file_hash

      t.text    :remark

      t.integer  :lock_version, default: 0, null: false
      t.string   :created_by, null: false
      t.string   :updated_by, null: false
      t.datetime :deleted_at
      
      t.timestamps null: false
    end

    add_index :tb_customer_properties, :document_no, unique: true
    add_index :tb_customer_properties, :uuid, unique: true
    add_index :tb_customer_properties, :doc_approved_file_hash
    add_index :tb_customer_properties, :created_by
    add_index :tb_customer_properties, :updated_by
  end
end
