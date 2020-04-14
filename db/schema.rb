# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_13_151917) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accesses", force: :cascade do |t|
    t.bigint "dro_id"
    t.string "access"
    t.string "copyright"
    t.string "download"
    t.string "readLocation"
    t.string "useAndReproductionStatement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dro_id"], name: "index_accesses_on_dro_id", unique: true
  end

  create_table "droStructurals", force: :cascade do |t|
    t.bigint "dro_id"
    t.string "isMemberOf"
    t.string "hasAgreement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dro_id"], name: "index_droStructurals_on_dro_id", unique: true
  end

  create_table "dros", force: :cascade do |t|
    t.string "type", null: false
    t.string "externalIdentifier", null: false
    t.string "label", null: false
    t.integer "version", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["externalIdentifier"], name: "index_dros_on_externalIdentifier", unique: true
  end

  create_table "fileSets", force: :cascade do |t|
    t.bigint "droStructural_id"
    t.string "type", null: false
    t.string "externalIdentifier", null: false
    t.string "label", null: false
    t.integer "version", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["droStructural_id", "externalIdentifier"], name: "index_fileSets_on_droStructural_id_and_externalIdentifier", unique: true
    t.index ["droStructural_id"], name: "index_fileSets_on_droStructural_id"
  end

  create_table "sequences", force: :cascade do |t|
    t.bigint "droStructural_id"
    t.string "viewingDirection"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["droStructural_id", "viewingDirection"], name: "index_sequences_on_droStructural_id_and_viewingDirection", unique: true
    t.index ["droStructural_id"], name: "index_sequences_on_droStructural_id"
  end

  add_foreign_key "accesses", "dros"
  add_foreign_key "droStructurals", "dros"
  add_foreign_key "fileSets", "\"droStructurals\"", column: "droStructural_id"
  add_foreign_key "sequences", "\"droStructurals\"", column: "droStructural_id"
end
