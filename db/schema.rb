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

ActiveRecord::Schema[7.0].define(version: 2023_04_28_213756) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "armies", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "group"
    t.text "notes"
    t.string "region"
    t.string "lord"
    t.text "tags", default: [], array: true
    t.string "col0"
    t.string "col1"
    t.string "col2"
    t.string "col3"
    t.string "col4"
    t.string "col5"
    t.string "col6"
    t.string "col7"
    t.string "col8"
    t.string "col9"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "armies_factions", force: :cascade do |t|
    t.bigint "army_id"
    t.bigint "faction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["army_id"], name: "index_armies_factions_on_army_id"
    t.index ["faction_id"], name: "index_armies_factions_on_faction_id"
  end

  create_table "factions", force: :cascade do |t|
    t.string "name"
    t.string "long_name"
    t.integer "discourse_id"
    t.integer "reputation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "game_id"
    t.index ["game_id"], name: "index_factions_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "prefix"
    t.string "icon_url"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "role", default: "player"
    t.integer "sort", default: 0
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "player"
    t.string "faction"
    t.integer "discourse_id"
    t.string "avatar_url"
    t.string "auth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "faction_id"
    t.index ["faction_id"], name: "index_users_on_faction_id"
  end

  add_foreign_key "armies_factions", "armies"
  add_foreign_key "armies_factions", "factions"
end
