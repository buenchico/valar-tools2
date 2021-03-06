# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_13_221020) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "factions", force: :cascade do |t|
    t.string "name"
    t.string "long_name"
    t.integer "discourse_id"
    t.boolean "active"
    t.integer "reputation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "prefix"
    t.string "icon_url"
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "games_tools", id: false, force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "tool_id"
    t.index ["game_id"], name: "index_games_tools_on_game_id"
    t.index ["tool_id"], name: "index_games_tools_on_tool_id"
  end

  create_table "tools", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "short_title"
    t.string "icon_url"
    t.text "options", default: [], array: true
    t.boolean "master", default: false
    t.integer "sort", default: 0
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "player"
    t.string "faction"
    t.integer "discourse_id"
    t.string "avatar_url"
    t.string "auth_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "faction_id"
    t.index ["faction_id"], name: "index_users_on_faction_id"
  end

end
