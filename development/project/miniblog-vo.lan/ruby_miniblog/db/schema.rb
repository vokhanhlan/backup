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

ActiveRecord::Schema.define(version: 20150316074138) do

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",    limit: 255, null: false
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size",    limit: 4
    t.integer  "assetable_id",      limit: 4
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "content",    limit: 65535,                null: false
    t.integer  "user_id",    limit: 4,                    null: false
    t.integer  "post_id",    limit: 4,                    null: false
    t.integer  "parent_id",  limit: 4,     default: 0
    t.boolean  "status",     limit: 1,     default: true
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "post_to_categories", force: :cascade do |t|
    t.integer  "category_id", limit: 4, null: false
    t.integer  "post_id",     limit: 4, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title",              limit: 200,                   null: false
    t.string   "description",        limit: 255,                   null: false
    t.text     "content",            limit: 65535,                 null: false
    t.integer  "user_id",            limit: 4,                     null: false
    t.boolean  "status",             limit: 1,     default: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",            limit: 40,                    null: false
    t.string   "password",            limit: 150,                   null: false
    t.string   "first_name",          limit: 50,                    null: false
    t.string   "last_name",           limit: 50,                    null: false
    t.boolean  "gender",              limit: 1,   default: true
    t.string   "permission",          limit: 5,   default: "11000"
    t.string   "email",               limit: 60,                    null: false
    t.string   "display_name",        limit: 50
    t.string   "birthday",            limit: 10,                    null: false
    t.string   "address",             limit: 50
    t.boolean  "status",              limit: 1,   default: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "password_salt",       limit: 255
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",    limit: 4
    t.datetime "avatar_updated_at"
  end

end
