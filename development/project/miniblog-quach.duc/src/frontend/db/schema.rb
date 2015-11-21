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

ActiveRecord::Schema.define(version: 20150324094441) do

  create_table "comments", force: :cascade do |t|
    t.text     "content",    limit: 65535, null: false
    t.integer  "user_id",    limit: 4,     null: false
    t.integer  "post_id",    limit: 4,     null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title",          limit: 200,                   null: false
    t.string   "description",    limit: 255,                   null: false
    t.text     "content",        limit: 65535,                 null: false
    t.string   "thumbnail",      limit: 100
    t.string   "thumbnail_path", limit: 100
    t.integer  "user_id",        limit: 4,                     null: false
    t.boolean  "status",         limit: 1,     default: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",      limit: 255
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
    t.string   "email",         limit: 255
    t.string   "address",       limit: 255
    t.string   "password_hash", limit: 255
    t.string   "password_salt", limit: 255
    t.string   "avatar",        limit: 255
    t.string   "avatar_path",   limit: 255
    t.boolean  "gender",        limit: 1
    t.string   "birthday",      limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

end
