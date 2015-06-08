# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150605004358) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "file_upload_meta", force: :cascade do |t|
    t.string   "file_name",   null: false
    t.string   "file_hash",   null: false
    t.string   "uploaded_by"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "file_upload_meta", ["file_hash"], name: "index_file_upload_meta_on_file_hash", using: :btree
  add_index "file_upload_meta", ["file_name"], name: "index_file_upload_meta_on_file_name", using: :btree

  create_table "file_uploads", force: :cascade do |t|
    t.binary   "file_data",    null: false
    t.string   "file_hash",    null: false
    t.decimal  "file_size",    null: false
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_uploads", ["file_hash"], name: "index_file_uploads_on_file_hash", unique: true, using: :btree

  create_table "ref_customers", force: :cascade do |t|
    t.string   "display_name",                        null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_customers", ["display_name"], name: "index_ref_customers_on_display_name", using: :btree
  add_index "ref_customers", ["uuid"], name: "index_ref_customers_on_uuid", unique: true, using: :btree

  create_table "ref_departments", force: :cascade do |t|
    t.string   "display_name",                        null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_departments", ["display_name"], name: "index_ref_departments_on_display_name", using: :btree
  add_index "ref_departments", ["uuid"], name: "index_ref_departments_on_uuid", unique: true, using: :btree

  create_table "ref_freight_terms", force: :cascade do |t|
    t.string   "display_name",                        null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_freight_terms", ["display_name"], name: "index_ref_freight_terms_on_display_name", using: :btree
  add_index "ref_freight_terms", ["uuid"], name: "index_ref_freight_terms_on_uuid", unique: true, using: :btree

  create_table "ref_models", force: :cascade do |t|
    t.string   "display_name",                        null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_models", ["display_name"], name: "index_ref_models_on_display_name", using: :btree
  add_index "ref_models", ["uuid"], name: "index_ref_models_on_uuid", unique: true, using: :btree

  create_table "ref_part_names", force: :cascade do |t|
    t.string   "display_name",                        null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_part_names", ["display_name"], name: "index_ref_part_names_on_display_name", using: :btree
  add_index "ref_part_names", ["uuid"], name: "index_ref_part_names_on_uuid", unique: true, using: :btree

  create_table "ref_request_bies", force: :cascade do |t|
    t.string   "display_name",                        null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_request_bies", ["display_name"], name: "index_ref_request_bies_on_display_name", using: :btree
  add_index "ref_request_bies", ["uuid"], name: "index_ref_request_bies_on_uuid", unique: true, using: :btree

  create_table "ref_unit_prices", force: :cascade do |t|
    t.string   "display_name",                        null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_unit_prices", ["display_name"], name: "index_ref_unit_prices_on_display_name", using: :btree
  add_index "ref_unit_prices", ["uuid"], name: "index_ref_unit_prices_on_uuid", unique: true, using: :btree

  create_table "ref_units", force: :cascade do |t|
    t.string   "display_name",                        null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_units", ["display_name"], name: "index_ref_units_on_display_name", using: :btree
  add_index "ref_units", ["uuid"], name: "index_ref_units_on_uuid", unique: true, using: :btree

  create_table "sys_config_by_dates", force: :cascade do |t|
    t.date     "effective_date",                                      null: false
    t.string   "config_key",                                          null: false
    t.decimal  "numeric_value",  precision: 20, scale: 6
    t.text     "string_value"
    t.integer  "lock_version",                            default: 0, null: false
    t.string   "created_by",                                          null: false
    t.string   "updated_by",                                          null: false
    t.string   "uuid",                                                null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "sys_config_by_dates", ["created_by"], name: "index_sys_config_by_dates_on_created_by", using: :btree
  add_index "sys_config_by_dates", ["updated_by"], name: "index_sys_config_by_dates_on_updated_by", using: :btree
  add_index "sys_config_by_dates", ["uuid"], name: "index_sys_config_by_dates_on_uuid", unique: true, using: :btree

  create_table "sys_configs", force: :cascade do |t|
    t.string   "config_key",                                         null: false
    t.decimal  "numeric_value", precision: 20, scale: 6
    t.text     "string_value"
    t.integer  "lock_version",                           default: 0
    t.string   "created_by",                                         null: false
    t.string   "updated_by",                                         null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "sys_configs", ["created_by"], name: "index_sys_configs_on_created_by", using: :btree
  add_index "sys_configs", ["updated_by"], name: "index_sys_configs_on_updated_by", using: :btree

  create_table "sys_dummies", force: :cascade do |t|
    t.string   "dummy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sys_seqs", force: :cascade do |t|
    t.string   "seq_type",    null: false
    t.date     "seq_date",    null: false
    t.integer  "last_number"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "tb_customer_properties", force: :cascade do |t|
    t.string   "document_no",                        null: false
    t.string   "uuid",                               null: false
    t.text     "description"
    t.string   "ref_request_by_uuid"
    t.string   "ref_department_uuid"
    t.integer  "request_qty"
    t.string   "ref_unit_uuid"
    t.date     "cmd_issue_date"
    t.date     "require_date"
    t.string   "status"
    t.string   "doc_approved_file_name"
    t.string   "doc_approved_file_hash"
    t.text     "remark"
    t.integer  "lock_version",           default: 0, null: false
    t.string   "created_by",                         null: false
    t.string   "updated_by",                         null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "tb_customer_properties", ["created_by"], name: "index_tb_customer_properties_on_created_by", using: :btree
  add_index "tb_customer_properties", ["doc_approved_file_hash"], name: "index_tb_customer_properties_on_doc_approved_file_hash", using: :btree
  add_index "tb_customer_properties", ["document_no"], name: "index_tb_customer_properties_on_document_no", unique: true, using: :btree
  add_index "tb_customer_properties", ["updated_by"], name: "index_tb_customer_properties_on_updated_by", using: :btree
  add_index "tb_customer_properties", ["uuid"], name: "index_tb_customer_properties_on_uuid", unique: true, using: :btree

  create_table "tb_customer_tools", force: :cascade do |t|
    t.string   "customer_prop_uuid", null: false
    t.date     "tool_receive_date"
    t.string   "invoice_no"
    t.integer  "receive_qty"
    t.integer  "row_no"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "tb_customer_tools", ["customer_prop_uuid"], name: "index_tb_customer_tools_on_customer_prop_uuid", using: :btree

  create_table "tb_die_molds", force: :cascade do |t|
    t.string   "file_hash"
    t.integer  "row_no"
    t.string   "created_by",                                   null: false
    t.string   "updated_by",                                   null: false
    t.string   "invoice_no"
    t.date     "invoice_date"
    t.string   "vendor"
    t.string   "by"
    t.string   "boi_name"
    t.string   "description"
    t.string   "dm_type"
    t.string   "ref_model_uuid"
    t.string   "model"
    t.string   "asset_ref"
    t.integer  "quantity"
    t.string   "ref_unit_uuid"
    t.string   "unit"
    t.decimal  "unit_price",          precision: 20, scale: 2
    t.string   "currency"
    t.string   "ref_department_uuid"
    t.string   "department"
    t.string   "import_tr"
    t.string   "import_rtm"
    t.date     "receive_date"
    t.string   "user_receive_by"
    t.string   "status"
    t.string   "install_delivery"
    t.string   "description_return0"
    t.string   "rtm_invoice0"
    t.string   "for0"
    t.integer  "return_qty0"
    t.string   "asset_doc0"
    t.string   "return_by_invoice0"
    t.date     "send_date_oversea0"
    t.string   "vendor_return0"
    t.string   "remark_oversea0"
    t.string   "description_return1"
    t.string   "rtm_invoice1"
    t.string   "for1"
    t.integer  "return_qty1"
    t.string   "asset_doc1"
    t.string   "return_by_invoice1"
    t.date     "send_date_oversea1"
    t.string   "vendor_return1"
    t.string   "remark_oversea1"
    t.string   "description_return2"
    t.string   "rtm_invoice2"
    t.string   "for2"
    t.integer  "return_qty2"
    t.string   "asset_doc2"
    t.string   "return_by_invoice2"
    t.date     "send_date_oversea2"
    t.string   "vendor_return2"
    t.string   "remark_oversea2"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "tb_die_molds", ["created_by"], name: "index_tb_die_molds_on_created_by", using: :btree
  add_index "tb_die_molds", ["file_hash"], name: "index_tb_die_molds_on_file_hash", using: :btree
  add_index "tb_die_molds", ["updated_by"], name: "index_tb_die_molds_on_updated_by", using: :btree

  create_table "tb_quotation_approve_files", force: :cascade do |t|
    t.string   "tb_quotation_uuid", null: false
    t.string   "file_hash",         null: false
    t.string   "file_name",         null: false
    t.string   "created_by",        null: false
    t.string   "updated_by",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tb_quotation_approve_files", ["created_by"], name: "index_tb_quotation_approve_files_on_created_by", using: :btree
  add_index "tb_quotation_approve_files", ["file_hash"], name: "index_tb_quotation_approve_files_on_file_hash", using: :btree
  add_index "tb_quotation_approve_files", ["file_name"], name: "index_tb_quotation_approve_files_on_file_name", using: :btree
  add_index "tb_quotation_approve_files", ["updated_by"], name: "index_tb_quotation_approve_files_on_updated_by", using: :btree

  create_table "tb_quotation_calculation_files", force: :cascade do |t|
    t.string   "tb_quotation_uuid", null: false
    t.string   "file_hash",         null: false
    t.string   "file_name",         null: false
    t.string   "created_by",        null: false
    t.string   "updated_by",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tb_quotation_calculation_files", ["created_by"], name: "index_tb_quotation_calculation_files_on_created_by", using: :btree
  add_index "tb_quotation_calculation_files", ["file_hash"], name: "index_tb_quotation_calculation_files_on_file_hash", using: :btree
  add_index "tb_quotation_calculation_files", ["file_name"], name: "index_tb_quotation_calculation_files_on_file_name", using: :btree
  add_index "tb_quotation_calculation_files", ["updated_by"], name: "index_tb_quotation_calculation_files_on_updated_by", using: :btree

  create_table "tb_quotation_items", force: :cascade do |t|
    t.string   "quotation_uuid",                                           null: false
    t.string   "item_code"
    t.string   "ref_model_uuid",                                           null: false
    t.string   "sub_code"
    t.string   "customer_code"
    t.decimal  "part_price",                      precision: 20, scale: 4
    t.decimal  "package_price",                   precision: 20, scale: 4
    t.string   "ref_unit_price_uuid",                                      null: false
    t.string   "po_reference",        limit: 400
    t.string   "remark",              limit: 400
    t.string   "file_hash",                                                null: false
    t.string   "created_by",                                               null: false
    t.string   "updated_by",                                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "row_no",                                                   null: false
    t.string   "part_name"
  end

  add_index "tb_quotation_items", ["created_by"], name: "index_tb_quotation_items_on_created_by", using: :btree
  add_index "tb_quotation_items", ["customer_code"], name: "index_tb_quotation_items_on_customer_code", using: :btree
  add_index "tb_quotation_items", ["file_hash"], name: "index_tb_quotation_items_on_file_hash", using: :btree
  add_index "tb_quotation_items", ["part_name"], name: "index_tb_quotation_items_on_part_name", using: :btree
  add_index "tb_quotation_items", ["quotation_uuid"], name: "index_tb_quotation_items_on_quotation_uuid", using: :btree
  add_index "tb_quotation_items", ["ref_model_uuid"], name: "index_tb_quotation_items_on_ref_model_uuid", using: :btree
  add_index "tb_quotation_items", ["ref_unit_price_uuid"], name: "index_tb_quotation_items_on_ref_unit_price_uuid", using: :btree
  add_index "tb_quotation_items", ["updated_by"], name: "index_tb_quotation_items_on_updated_by", using: :btree

  create_table "tb_quotations", force: :cascade do |t|
    t.string   "uuid",                  limit: 36,                                      null: false
    t.string   "quotation_no"
    t.string   "ref_customer_uuid",     limit: 36,                                      null: false
    t.date     "issue_date"
    t.string   "ref_freight_term_uuid"
    t.decimal  "exchange_rate",                    precision: 20, scale: 4
    t.integer  "lock_version",                                              default: 0, null: false
    t.string   "created_by",                                                            null: false
    t.string   "updated_by",                                                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "tb_quotations", ["created_by"], name: "index_tb_quotations_on_created_by", using: :btree
  add_index "tb_quotations", ["quotation_no"], name: "index_tb_quotations_on_quotation_no", unique: true, using: :btree
  add_index "tb_quotations", ["ref_customer_uuid"], name: "index_tb_quotations_on_ref_customer_uuid", using: :btree
  add_index "tb_quotations", ["ref_freight_term_uuid"], name: "index_tb_quotations_on_ref_freight_term_uuid", using: :btree
  add_index "tb_quotations", ["updated_by"], name: "index_tb_quotations_on_updated_by", using: :btree
  add_index "tb_quotations", ["uuid"], name: "index_tb_quotations_on_uuid", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",                   default: 0,     null: false
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid",                   limit: 36,                 null: false
    t.string   "user_name",                                         null: false
    t.string   "first_name",                                        null: false
    t.string   "last_name"
    t.boolean  "is_admin",                          default: false
    t.string   "timezone"
    t.integer  "lock_version",                      default: 0
    t.string   "created_by"
    t.string   "updated_by"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uuid"], name: "index_users_on_uuid", unique: true, using: :btree

end
