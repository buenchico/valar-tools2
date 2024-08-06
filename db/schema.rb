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

ActiveRecord::Schema[7.0].define(version: 2024_08_06_170528) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "location_id"
    t.bigint "family_id"
    t.string "board"
    t.text "logs", default: [], array: true
    t.index ["family_id"], name: "index_valar_armies_on_family_id"
    t.index ["location_id"], name: "index_valar_armies_on_location_id"
  end

  create_table "armies_factions", force: :cascade do |t|
    t.bigint "army_id"
    t.bigint "faction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["army_id"], name: "index_valar_armies_factions_on_army_id"
    t.index ["faction_id"], name: "index_valar_armies_factions_on_faction_id"
  end

  create_table "battles", force: :cascade do |t|
    t.string "name"
    t.datetime "date"
    t.string "terrain"
    t.string "integer"
    t.integer "status"
    t.string "side_a"
    t.string "side_b"
    t.jsonb "skirmish", default: {"rolls"=>nil, "armies"=>nil, "tokens"=>nil, "results"=>nil, "strategy"=>nil}
    t.jsonb "engagement", default: {"rolls"=>nil, "armies"=>nil, "tokens"=>nil, "results"=>nil, "strategy"=>nil}
    t.jsonb "combat_1", default: {"rolls"=>nil, "armies"=>nil, "tokens"=>nil, "results"=>nil, "strategy"=>nil}
    t.jsonb "combat_2", default: {"rolls"=>nil, "armies"=>nil, "tokens"=>nil, "results"=>nil, "strategy"=>nil}
    t.jsonb "combat_3", default: {"rolls"=>nil, "armies"=>nil, "tokens"=>nil, "results"=>nil, "strategy"=>nil}
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_valar_battles_on_user_id"
  end

  create_table "clocks", force: :cascade do |t|
    t.string "name"
    t.string "style", default: "clock"
    t.integer "status", default: 0
    t.integer "size"
    t.integer "outcome", default: 0
    t.string "description"
    t.string "logs", default: [], array: true
    t.boolean "visible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id"
    t.text "left"
    t.text "right"
    t.index ["family_id"], name: "index_valar_clocks_on_family_id"
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
    t.string "pov"
    t.string "tokens"
    t.jsonb "fleets"
    t.string "fleets_notes"
    t.integer "category_id"
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
    t.string "members"
    t.integer "loyalty_1"
    t.integer "loyalty_2"
    t.integer "loyalty_3"
    t.integer "loyalty_4"
    t.integer "loyalty_5"
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
    t.integer "category_id"
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
    t.jsonb "line", default: []
    t.integer "priority", limit: 2, default: 0
    t.jsonb "polygon", default: []
    t.index ["family_id"], name: "index_valar_locations_on_family_id"
    t.index ["game_id"], name: "index_valar_locations_on_game_id"
    t.index ["region_id"], name: "index_valar_locations_on_region_id"
  end

  create_table "missions", force: :cascade do |t|
    t.string "name"
    t.integer "discourse_id"
    t.string "status"
    t.string "notes"
    t.date "started"
    t.date "resolved"
    t.bigint "game_id", null: false
    t.bigint "faction_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faction_id"], name: "index_valar_missions_on_faction_id"
    t.index ["game_id"], name: "index_valar_missions_on_game_id"
    t.index ["user_id"], name: "index_valar_missions_on_user_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "name"
    t.string "section"
    t.string "description"
    t.integer "difficulty"
    t.integer "speed"
    t.text "factors", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  add_foreign_key "battles", "users"
  add_foreign_key "factions_games", "factions"
  add_foreign_key "factions_games", "games"
  add_foreign_key "families", "families", column: "lord_id"
  add_foreign_key "locations", "locations", column: "region_id"
  add_foreign_key "missions", "factions"
  add_foreign_key "missions", "games"
  add_foreign_key "missions", "users"
end
