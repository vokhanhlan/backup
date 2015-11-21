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

ActiveRecord::Schema.define(version: 20141205053829) do

  create_table "comments", force: true do |t|
    t.string   "title",            limit: 50, default: ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "nguoi_dung_id"
    t.string   "role",                        default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["nguoi_dung_id"], name: "index_comments_on_nguoi_dung_id", using: :btree

  create_table "loai_san_phams", force: true do |t|
    t.string   "ten"
    t.integer  "ma_loai_cha"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nguoi_dungs", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nguoi_dungs", ["email"], name: "index_nguoi_dungs_on_email", unique: true, using: :btree
  add_index "nguoi_dungs", ["reset_password_token"], name: "index_nguoi_dungs_on_reset_password_token", unique: true, using: :btree

  create_table "nguoi_dungs_roles", id: false, force: true do |t|
    t.integer "nguoi_dung_id"
    t.integer "role_id"
  end

  add_index "nguoi_dungs_roles", ["nguoi_dung_id", "role_id"], name: "index_nguoi_dungs_roles_on_nguoi_dung_id_and_role_id", using: :btree

  create_table "nha_cung_caps", force: true do |t|
    t.string   "ten"
    t.string   "dia_chi"
    t.string   "email"
    t.string   "so_dien_thoai"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "san_phams", force: true do |t|
    t.integer  "ma_loai_san_pham"
    t.integer  "ma_nha_cung_cap"
    t.string   "ten"
    t.float    "don_gia",           limit: 24
    t.text     "mo_ta"
    t.integer  "san_pham_moi"
    t.integer  "trang_thai"
    t.date     "ngay_san_xuat"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hinh_file_name"
    t.string   "hinh_content_type"
    t.integer  "hinh_file_size"
    t.datetime "hinh_updated_at"
  end

end
