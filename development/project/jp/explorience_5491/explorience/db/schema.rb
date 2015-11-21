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

ActiveRecord::Schema.define(version: 20150625033627) do

  create_table "action_logs", force: :cascade do |t|
    t.integer  "user_id",                      limit: 4
    t.integer  "refered_experience_detail",    limit: 4,   default: 0
    t.integer  "refered_score_logs",           limit: 4,   default: 0
    t.integer  "refered_upload_photos",        limit: 4,   default: 0
    t.integer  "refered_menu_guide",           limit: 4,   default: 0
    t.integer  "refered_menu_privacy_policy",  limit: 4,   default: 0
    t.integer  "refered_user_page",            limit: 4,   default: 0
    t.integer  "refered_other_users_sns",      limit: 4,   default: 0
    t.integer  "refered_other_site",           limit: 4,   default: 0
    t.integer  "used_display_recommended",     limit: 4,   default: 0
    t.integer  "used_display_timeline",        limit: 4,   default: 0
    t.integer  "used_display_weekly_ranking",  limit: 4,   default: 0
    t.integer  "used_display_monthly_ranking", limit: 4,   default: 0
    t.integer  "used_display_map",             limit: 4,   default: 0
    t.integer  "used_filter_by_tag",           limit: 4,   default: 0
    t.integer  "used_change_settings",         limit: 4,   default: 0
    t.integer  "used_share_for_sns",           limit: 4,   default: 0
    t.string   "visitor_ids",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "action_logs", ["user_id"], name: "index_action_logs_on_user_id", using: :btree

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "advertisers", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "ad_type",    limit: 1,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "affiliations", force: :cascade do |t|
    t.integer  "experience_id", limit: 4
    t.integer  "user_id",       limit: 4
    t.integer  "action_type",   limit: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "affiliations", ["experience_id"], name: "index_affiliations_on_experience_id", using: :btree

  create_table "clickings", force: :cascade do |t|
    t.integer  "experience_id", limit: 4
    t.integer  "user_id",       limit: 4
    t.integer  "context",       limit: 1,                 null: false
    t.boolean  "deleted",       limit: 1, default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clickings", ["experience_id"], name: "index_clickings_on_experience_id", using: :btree
  add_index "clickings", ["user_id"], name: "index_clickings_on_user_id", using: :btree

  create_table "experience_photos", force: :cascade do |t|
    t.integer  "photo_id",      limit: 4
    t.integer  "experience_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "experience_photos", ["experience_id"], name: "index_experience_photos_on_experience_id", using: :btree
  add_index "experience_photos", ["photo_id"], name: "index_experience_photos_on_photo_id", using: :btree

  create_table "experience_translations", force: :cascade do |t|
    t.integer  "experience_id", limit: 4,     null: false
    t.string   "locale",        limit: 255,   null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "title",         limit: 255
    t.text     "description",   limit: 65535
    t.string   "address",       limit: 255
    t.text     "workday",       limit: 65535
  end

  add_index "experience_translations", ["experience_id"], name: "index_experience_translations_on_experience_id", using: :btree
  add_index "experience_translations", ["locale"], name: "index_experience_translations_on_locale", using: :btree

  create_table "experiences", force: :cascade do |t|
    t.integer  "advertiser_id", limit: 4
    t.string   "tel",           limit: 255
    t.string   "url",           limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "price",         limit: 4
    t.integer  "score",         limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author",        limit: 4
  end

  add_index "experiences", ["advertiser_id"], name: "index_experiences_on_advertiser_id", using: :btree

  create_table "fixed_photos", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "experience_id", limit: 4
    t.integer  "photo_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fixed_photos", ["user_id"], name: "index_fixed_photos_on_user_id", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "following_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read",         limit: 1, default: false
  end

  add_index "follows", ["user_id"], name: "index_follows_on_user_id", using: :btree

  create_table "guide_translations", force: :cascade do |t|
    t.integer  "guide_id",   limit: 4,     null: false
    t.string   "locale",     limit: 255,   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "title",      limit: 255
    t.text     "body",       limit: 65535
  end

  add_index "guide_translations", ["guide_id"], name: "index_guide_translations_on_guide_id", using: :btree
  add_index "guide_translations", ["locale"], name: "index_guide_translations_on_locale", using: :btree

  create_table "guides", force: :cascade do |t|
    t.integer  "section",    limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "initial_data_files", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invalid_images", force: :cascade do |t|
    t.integer  "photo_id",    limit: 4
    t.integer  "uploader_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invalid_images", ["photo_id"], name: "index_invalid_images_on_photo_id", using: :btree
  add_index "invalid_images", ["uploader_id"], name: "index_invalid_images_on_uploader_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "img_file_name",    limit: 255
    t.string   "img_content_type", limit: 255
    t.integer  "img_file_size",    limit: 4
    t.datetime "img_updated_at"
    t.boolean  "published",        limit: 1,   default: true
  end

  create_table "providers", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "sns_type",   limit: 1,   null: false
    t.string   "sns_id",     limit: 255, null: false
    t.string   "nickname",   limit: 40
    t.string   "language",   limit: 8
    t.string   "photo_url",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "providers", ["user_id"], name: "index_providers_on_user_id", using: :btree

  create_table "rankings", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "experience_id", limit: 4
    t.integer  "rank",          limit: 4
    t.boolean  "locked",        limit: 1, default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rankings", ["experience_id"], name: "index_rankings_on_experience_id", using: :btree
  add_index "rankings", ["user_id"], name: "index_rankings_on_user_id", using: :btree

  create_table "reporters", force: :cascade do |t|
    t.integer  "invalid_image_id", limit: 4
    t.integer  "user_id",          limit: 4
    t.string   "email",            limit: 255,   default: "", null: false
    t.integer  "invalid_type",     limit: 1,                  null: false
    t.text     "reason",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reporters", ["invalid_image_id"], name: "index_reporters_on_invalid_image_id", using: :btree
  add_index "reporters", ["user_id"], name: "index_reporters_on_user_id", using: :btree

  create_table "score_logs", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "other_user_id",     limit: 4
    t.integer  "scored_type",       limit: 1,                   null: false
    t.string   "placeholder_key",   limit: 255
    t.string   "placeholder_value", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read",              limit: 1,   default: false
  end

  add_index "score_logs", ["user_id"], name: "index_score_logs_on_user_id", using: :btree

  create_table "tag_translations", force: :cascade do |t|
    t.integer  "tag_id",     limit: 4,   null: false
    t.string   "locale",     limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "name",       limit: 255
  end

  add_index "tag_translations", ["locale"], name: "index_tag_translations_on_locale", using: :btree
  add_index "tag_translations", ["name"], name: "index_tag_translations_on_name", unique: true, using: :btree
  add_index "tag_translations", ["tag_id"], name: "index_tag_translations_on_tag_id", using: :btree

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

  create_table "user_photos", force: :cascade do |t|
    t.integer  "photo_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_photos", ["photo_id"], name: "index_user_photos_on_photo_id", using: :btree
  add_index "user_photos", ["user_id"], name: "index_user_photos_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                     limit: 40,               null: false
    t.string   "email",                    limit: 255, default: "", null: false
    t.integer  "score",                    limit: 4,   default: 0
    t.datetime "last_sign_in_checking_at"
    t.string   "encrypted_password",       limit: 255, default: "", null: false
    t.string   "reset_password_token",     limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",       limit: 255
    t.string   "last_sign_in_ip",          limit: 255
    t.string   "confirmation_token",       limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type",                limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
