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

ActiveRecord::Schema.define(version: 20150520073316) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "file_uploads", force: true do |t|
    t.string   "file_name",   null: false
    t.string   "file_hash",   null: false
    t.decimal  "file_size"
    t.string   "uploaded_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_uploads", ["file_hash"], name: "index_file_uploads_on_file_hash", using: :btree
  add_index "file_uploads", ["file_name"], name: "index_file_uploads_on_file_name", using: :btree

  create_table "ref_customers", force: true do |t|
    t.string   "cust_name",                           null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_customers", ["cust_name"], name: "index_ref_customers_on_cust_name", using: :btree
  add_index "ref_customers", ["uuid"], name: "index_ref_customers_on_uuid", unique: true, using: :btree

  create_table "ref_freight_terms", force: true do |t|
    t.string   "freight_term",                        null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_freight_terms", ["freight_term"], name: "index_ref_freight_terms_on_freight_term", using: :btree
  add_index "ref_freight_terms", ["uuid"], name: "index_ref_freight_terms_on_uuid", unique: true, using: :btree

  create_table "ref_models", force: true do |t|
    t.string   "model_name",                          null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_models", ["model_name"], name: "index_ref_models_on_model_name", using: :btree
  add_index "ref_models", ["uuid"], name: "index_ref_models_on_uuid", unique: true, using: :btree

  create_table "ref_part_names", force: true do |t|
    t.string   "part_name",                           null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_part_names", ["part_name"], name: "index_ref_part_names_on_part_name", using: :btree
  add_index "ref_part_names", ["uuid"], name: "index_ref_part_names_on_uuid", unique: true, using: :btree

  create_table "ref_unit_prices", force: true do |t|
    t.string   "unit_name",                           null: false
    t.text     "remark"
    t.string   "uuid",         limit: 36,             null: false
    t.integer  "lock_version",            default: 0, null: false
    t.datetime "deleted_at"
    t.string   "created_by",                          null: false
    t.string   "updated_by",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ref_unit_prices", ["unit_name"], name: "index_ref_unit_prices_on_unit_name", using: :btree
  add_index "ref_unit_prices", ["uuid"], name: "index_ref_unit_prices_on_uuid", unique: true, using: :btree

  create_table "sys_config_by_dates", force: true do |t|
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

  create_table "sys_configs", force: true do |t|
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

  create_table "sys_dummies", force: true do |t|
    t.string   "dummy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sys_seqs", force: true do |t|
    t.string   "seq_type",    null: false
    t.date     "seq_date",    null: false
    t.integer  "last_number"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "tb_quotation_approve_files", force: true do |t|
    t.string   "tb_quotation_uuid", null: false
    t.string   "file_hash",         null: false
    t.string   "file_name",         null: false
    t.string   "created_by",        null: false
    t.string   "updated_by",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tb_quotation_approve_files", ["created_by"], name: "index_tb_quotation_approve_files_on_created_by", using: :btree
  add_index "tb_quotation_approve_files", ["file_hash"], name: "index_tb_quotation_approve_files_on_file_hash", unique: true, using: :btree
  add_index "tb_quotation_approve_files", ["file_name"], name: "index_tb_quotation_approve_files_on_file_name", using: :btree
  add_index "tb_quotation_approve_files", ["updated_by"], name: "index_tb_quotation_approve_files_on_updated_by", using: :btree

  create_table "tb_quotation_calculation_files", force: true do |t|
    t.string   "tb_quotation_uuid", null: false
    t.string   "file_hash",         null: false
    t.string   "file_name",         null: false
    t.string   "created_by",        null: false
    t.string   "updated_by",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tb_quotation_calculation_files", ["created_by"], name: "index_tb_quotation_calculation_files_on_created_by", using: :btree
  add_index "tb_quotation_calculation_files", ["file_hash"], name: "index_tb_quotation_calculation_files_on_file_hash", unique: true, using: :btree
  add_index "tb_quotation_calculation_files", ["file_name"], name: "index_tb_quotation_calculation_files_on_file_name", using: :btree
  add_index "tb_quotation_calculation_files", ["updated_by"], name: "index_tb_quotation_calculation_files_on_updated_by", using: :btree

  create_table "tb_quotation_items", force: true do |t|
    t.string   "quotation_uuid",                                          null: false
    t.string   "item_code"
    t.string   "ref_model_uuid",                                          null: false
    t.string   "sub_code"
    t.string   "customer_code"
    t.string   "part_name"
    t.string   "ref_part_uuid",                                           null: false
    t.decimal  "part_price",                     precision: 20, scale: 2
    t.decimal  "package_price",                  precision: 20, scale: 2
    t.string   "ref_unit_price_ref",                                      null: false
    t.string   "po_reference",       limit: 400
    t.string   "remark",             limit: 400
    t.string   "file_hash",                                               null: false
    t.string   "created_by",                                              null: false
    t.string   "updated_by",                                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tb_quotation_items", ["created_by"], name: "index_tb_quotation_items_on_created_by", using: :btree
  add_index "tb_quotation_items", ["file_hash"], name: "index_tb_quotation_items_on_file_hash", using: :btree
  add_index "tb_quotation_items", ["quotation_uuid"], name: "index_tb_quotation_items_on_quotation_uuid", unique: true, using: :btree
  add_index "tb_quotation_items", ["ref_model_uuid"], name: "index_tb_quotation_items_on_ref_model_uuid", using: :btree
  add_index "tb_quotation_items", ["ref_unit_price_ref"], name: "index_tb_quotation_items_on_ref_unit_price_ref", using: :btree
  add_index "tb_quotation_items", ["updated_by"], name: "index_tb_quotation_items_on_updated_by", using: :btree

  create_table "tb_quotations", force: true do |t|
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
  end

  add_index "tb_quotations", ["created_by"], name: "index_tb_quotations_on_created_by", using: :btree
  add_index "tb_quotations", ["quotation_no"], name: "index_tb_quotations_on_quotation_no", using: :btree
  add_index "tb_quotations", ["ref_customer_uuid"], name: "index_tb_quotations_on_ref_customer_uuid", using: :btree
  add_index "tb_quotations", ["ref_freight_term_uuid"], name: "index_tb_quotations_on_ref_freight_term_uuid", using: :btree
  add_index "tb_quotations", ["updated_by"], name: "index_tb_quotations_on_updated_by", using: :btree
  add_index "tb_quotations", ["uuid"], name: "index_tb_quotations_on_uuid", unique: true, using: :btree

  create_table "users", force: true do |t|
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
