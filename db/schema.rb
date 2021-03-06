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

ActiveRecord::Schema.define(version: 20180718075335) do

  create_table "cache_configs", force: :cascade do |t|
    t.string   "key",        limit: 100, null: false
    t.string   "value",      limit: 512, null: false
    t.datetime "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cache_configs", ["key"], name: "idx_config_key", unique: true, using: :btree

  create_table "client_versions", force: :cascade do |t|
    t.integer  "client_type",  limit: 4
    t.integer  "version",      limit: 4
    t.string   "desc",         limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "download_url", limit: 2048
  end

  create_table "cp_sessions", force: :cascade do |t|
    t.string   "words_ids",         limit: 255
    t.string   "choices_words_ids", limit: 255
    t.integer  "user1_id",          limit: 4
    t.integer  "user2_id",          limit: 4
    t.string   "user1_choices",     limit: 255
    t.string   "user2_choices",     limit: 255
    t.string   "user1_used_time",   limit: 255
    t.string   "user2_used_time",   limit: 255
    t.integer  "user1_idx",         limit: 4
    t.integer  "user2_idx",         limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "ensure_codes", force: :cascade do |t|
    t.string   "phone",      limit: 255
    t.string   "code",       limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "status",     limit: 255, default: "0"
  end

  create_table "package_videos", force: :cascade do |t|
    t.integer  "package_id", limit: 4
    t.integer  "video_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "packages", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "title_cn",    limit: 255
    t.string   "desc",        limit: 255
    t.string   "poster",      limit: 255
    t.integer  "share_count", limit: 4,   default: 0
    t.integer  "play_count",  limit: 4,   default: 0
    t.integer  "star_count",  limit: 4,   default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "plan_alerts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "plan_id",    limit: 4
    t.integer  "hours",      limit: 4
    t.integer  "minutes",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "plan_records", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "plan_id",    limit: 4
    t.string   "desc",       limit: 255
    t.string   "images",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "start"
    t.datetime "end"
    t.string   "desc",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",    limit: 4,   null: false
  end

  create_table "user_learn_words", force: :cascade do |t|
    t.integer  "user_id",       limit: 4,               null: false
    t.integer  "learn_word_id", limit: 4,               null: false
    t.integer  "status",        limit: 4,   default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "video_id",      limit: 4
    t.string   "subtitle",      limit: 255
  end

  add_index "user_learn_words", ["user_id", "learn_word_id"], name: "index_user_learn_words_on_user_id_and_learn_word_id", unique: true, using: :btree

  create_table "user_packages", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "package_id", limit: 4
    t.integer  "ttype",      limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_packages", ["user_id", "package_id", "ttype"], name: "index_user_packages_on_user_id_and_package_id_and_ttype", unique: true, using: :btree

  create_table "user_rewards", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "reward_type", limit: 4
    t.integer  "content",     limit: 4
    t.integer  "state",       limit: 4
    t.string   "token",       limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "user_videos", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "video_id",   limit: 4
    t.integer  "uvtype",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_videos", ["user_id", "video_id", "uvtype"], name: "index_user_videos_on_user_id_and_video_id_and_uvtype", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "nick_name",    limit: 255
    t.string   "avatar",       limit: 255
    t.integer  "gender",       limit: 4
    t.string   "access_token", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "provider",     limit: 4,   null: false
    t.string   "unionid",      limit: 255
    t.string   "openid",       limit: 255
    t.string   "country",      limit: 255
    t.string   "province",     limit: 255
    t.string   "city",         limit: 255
    t.string   "user_token",   limit: 255
    t.string   "name",         limit: 255
    t.string   "password",     limit: 255
    t.integer  "package_id",   limit: 4
  end

  create_table "utypes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "status",     limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "videos", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "title_cn",            limit: 255
    t.string   "author",              limit: 255
    t.string   "author_cn",           limit: 255
    t.string   "desc",                limit: 255
    t.string   "desc_cn",             limit: 255
    t.string   "video_url",           limit: 255
    t.string   "srt_url",             limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "poster",              limit: 255
    t.string   "video_file_name",     limit: 255
    t.string   "srt_file_name",       limit: 255
    t.string   "other_srt_url",       limit: 255
    t.string   "other_srt_file_name", limit: 255
    t.integer  "utype_id",            limit: 4
    t.integer  "share_count",         limit: 4,   default: 0
    t.integer  "play_count",          limit: 4,   default: 0
    t.integer  "star_count",          limit: 4,   default: 0
    t.integer  "level",               limit: 4,   default: 0
    t.integer  "words_count",         limit: 4,   default: 0
  end

end
