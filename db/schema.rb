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
    t.bigint "droFile_id"
    t.string "access"
    t.string "download"
    t.string "readLocation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["droFile_id"], name: "index_accesses_on_droFile_id", unique: true
  end

  create_table "droAccesses", force: :cascade do |t|
    t.bigint "dro_id"
    t.string "access"
    t.string "copyright"
    t.string "download"
    t.string "readLocation"
    t.string "useAndReproductionStatement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dro_id"], name: "index_droAccesses_on_dro_id", unique: true
  end

  create_table "droFiles", force: :cascade do |t|
    t.bigint "fileSetStructural_id"
    t.string "type", null: false
    t.string "externalIdentifier", null: false
    t.string "label", null: false
    t.string "filename"
    t.bigint "size"
    t.integer "version", null: false
    t.string "hasMimeType"
    t.string "use"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["fileSetStructural_id", "externalIdentifier"], name: "index_droFiles_on_fileSetStructural_id_and_externalIdentifier", unique: true
    t.index ["fileSetStructural_id"], name: "index_droFiles_on_fileSetStructural_id"
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

  create_table "embargoes", force: :cascade do |t|
    t.bigint "droAccess_id"
    t.datetime "releaseDate", null: false
    t.string "access", null: false
    t.string "useAndReproductionStatement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["droAccess_id"], name: "index_embargoes_on_droAccess_id", unique: true
  end

  create_table "fileAdministratives", force: :cascade do |t|
    t.bigint "droFile_id"
    t.boolean "sdrPreserve", null: false
    t.boolean "shelve", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["droFile_id"], name: "index_fileAdministratives_on_droFile_id", unique: true
  end

  create_table "fileSetStructurals", force: :cascade do |t|
    t.bigint "fileSet_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["fileSet_id"], name: "index_fileSetStructurals_on_fileSet_id", unique: true
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

  create_table "messageDigests", force: :cascade do |t|
    t.bigint "droFile_id"
    t.string "type", null: false
    t.string "digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["droFile_id", "type"], name: "index_messageDigests_on_droFile_id_and_type", unique: true
    t.index ["droFile_id"], name: "index_messageDigests_on_droFile_id"
  end

  create_table "presentations", force: :cascade do |t|
    t.bigint "droFile_id"
    t.integer "height"
    t.integer "width"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["droFile_id"], name: "index_presentations_on_droFile_id", unique: true
  end

  create_table "sequences", force: :cascade do |t|
    t.bigint "droStructural_id"
    t.string "viewingDirection"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["droStructural_id", "viewingDirection"], name: "index_sequences_on_droStructural_id_and_viewingDirection", unique: true
    t.index ["droStructural_id"], name: "index_sequences_on_droStructural_id"
  end

  add_foreign_key "accesses", "\"droFiles\"", column: "droFile_id"
  add_foreign_key "droAccesses", "dros"
  add_foreign_key "droFiles", "\"fileSetStructurals\"", column: "fileSetStructural_id"
  add_foreign_key "droStructurals", "dros"
  add_foreign_key "embargoes", "\"droAccesses\"", column: "droAccess_id"
  add_foreign_key "fileAdministratives", "\"droFiles\"", column: "droFile_id"
  add_foreign_key "fileSetStructurals", "\"fileSets\"", column: "fileSet_id"
  add_foreign_key "fileSets", "\"droStructurals\"", column: "droStructural_id"
  add_foreign_key "messageDigests", "\"droFiles\"", column: "droFile_id"
  add_foreign_key "presentations", "\"droFiles\"", column: "droFile_id"
  add_foreign_key "sequences", "\"droStructurals\"", column: "droStructural_id"
end
