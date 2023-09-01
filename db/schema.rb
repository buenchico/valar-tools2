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

ActiveRecord::Schema[7.0].define(version: 2023_09_01_163618) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "armies", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "group"
    t.string "position"
    t.text "notes"
    t.string "region"
    t.string "lord"
    t.boolean "visible"
    t.text "tags", default: [], array: true
    t.integer "hp", default: 100
    t.integer "col0"
    t.integer "col1"
    t.integer "col2"
    t.integer "col3"
    t.integer "col4"
    t.integer "col5"
    t.integer "col6"
    t.integer "col7"
    t.integer "col8"
    t.integer "col9"
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
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "flair_url"
  end

  create_table "factions_games", force: :cascade do |t|
    t.bigint "faction_id"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faction_id"], name: "index_factions_games_on_faction_id"
    t.index ["game_id"], name: "index_factions_games_on_game_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.string "tags", default: [], array: true
    t.string "branch"
    t.boolean "visible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "game_id"
    t.index ["game_id"], name: "index_families_on_game_id"
  end

  create_table "game_tools", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "tool_id"
    t.boolean "active", default: false
    t.jsonb "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_tools_on_game_id"
    t.index ["tool_id"], name: "index_game_tools_on_tool_id"
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

  create_table "locations", force: :cascade do |t|
    t.string "name_en"
    t.string "name_es"
    t.string "description"
    t.float "x"
    t.float "y"
    t.string "region"
    t.string "tags", default: [], array: true
    t.string "location_type"
    t.boolean "visible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id"
    t.bigint "game_id"
    t.index ["family_id"], name: "index_locations_on_family_id"
    t.index ["game_id"], name: "index_locations_on_game_id"
  end

  create_table "tools", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "short_title"
    t.string "icon_url"
    t.text "options_info", default: ""
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

  create_table "armies", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "group"
    t.string "position"
    t.text "notes"
    t.boolean "visible"
    t.text "tags", default: [], array: true
    t.integer "hp", default: 100
    t.integer "col0"
    t.integer "col1"
    t.integer "col2"
    t.integer "col3"
    t.integer "col4"
    t.integer "col5"
    t.integer "col6"
    t.integer "col7"
    t.integer "col8"
    t.integer "col9"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "region_id"
    t.bigint "lord_id"
    t.index ["lord_id"], name: "index_valar_armies_on_lord_id"
    t.index ["region_id"], name: "index_valar_armies_on_region_id"
  end

  create_table "armies_factions", force: :cascade do |t|
    t.bigint "army_id"
    t.bigint "faction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["army_id"], name: "index_valar_armies_factions_on_army_id"
    t.index ["faction_id"], name: "index_valar_armies_factions_on_faction_id"
  end

  create_table "factions", force: :cascade do |t|
    t.string "name"
    t.string "long_name"
    t.integer "discourse_id"
    t.integer "reputation"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "flair_url"
    t.string "description"
    t.string "title"
  end

  create_table "factions_games", force: :cascade do |t|
    t.bigint "faction_id"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faction_id"], name: "index_valar_factions_games_on_faction_id"
    t.index ["game_id"], name: "index_valar_factions_games_on_game_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.string "tags", default: [], array: true
    t.string "branch"
    t.boolean "visible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "game_id"
    t.bigint "faction_id"
    t.bigint "lord_id"
    t.string "description"
    t.index ["faction_id"], name: "index_valar_families_on_faction_id"
    t.index ["game_id"], name: "index_valar_families_on_game_id"
    t.index ["lord_id"], name: "index_valar_families_on_lord_id"
  end

  create_table "game_tools", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "tool_id"
    t.boolean "active", default: false
    t.jsonb "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_valar_game_tools_on_game_id"
    t.index ["tool_id"], name: "index_valar_game_tools_on_tool_id"
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

  create_table "locations", force: :cascade do |t|
    t.string "name_en"
    t.string "name_es"
    t.string "description"
    t.float "x"
    t.float "y"
    t.string "tags", default: [], array: true
    t.string "location_type"
    t.boolean "visible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id"
    t.bigint "game_id"
    t.bigint "region_id"
    t.index ["family_id"], name: "index_valar_locations_on_family_id"
    t.index ["game_id"], name: "index_valar_locations_on_game_id"
    t.index ["region_id"], name: "index_valar_locations_on_region_id"
  end

  create_table "tools", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "short_title"
    t.string "icon_url"
    t.text "options_info", default: ""
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
    t.index ["faction_id"], name: "index_valar_users_on_faction_id"
  end

  add_foreign_key "armies_factions", "armies"
  add_foreign_key "armies_factions", "factions"
  add_foreign_key "factions_games", "factions"
  add_foreign_key "factions_games", "games"
  add_foreign_key "armies", "families", column: "lord_id"
  add_foreign_key "armies", "locations", column: "region_id"
  add_foreign_key "armies_factions", "armies"
  add_foreign_key "armies_factions", "factions"
  add_foreign_key "factions_games", "factions"
  add_foreign_key "factions_games", "games"
  add_foreign_key "families", "families", column: "lord_id"
  add_foreign_key "locations", "locations", column: "region_id"
end
