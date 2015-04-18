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

ActiveRecord::Schema.define(version: 20150418100511) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string   "department",                                        null: false
    t.string   "timezone"
    t.integer  "lock_version",                      default: 0
    t.string   "created_by"
    t.string   "updated_by"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uuid"], name: "index_users_on_uuid", unique: true, using: :btree

end
