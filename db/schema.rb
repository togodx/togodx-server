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

ActiveRecord::Schema.define(version: 2021_09_06_085048) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attributes", force: :cascade do |t|
    t.string "api", null: false
    t.string "dataset", null: false
    t.string "datamodel", null: false
    t.index ["api"], name: "index_attributes_on_api", unique: true
  end

  create_table "classifications", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_classifications_on_classification"
    t.index ["leaf"], name: "index_classifications_on_leaf"
    t.index ["lft"], name: "index_classifications_on_lft"
    t.index ["parent_id"], name: "index_classifications_on_parent_id"
    t.index ["rgt"], name: "index_classifications_on_rgt"
  end

  create_table "distributions", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_distributions_on_distribution"
    t.index ["distribution_value"], name: "index_distributions_on_distribution_value"
  end

  create_table "properties", force: :cascade do |t|
    t.string "db", null: false
    t.string "entry", null: false
    t.string "key"
    t.string "value"
    t.index ["db"], name: "index_properties_on_db"
    t.index ["entry"], name: "index_properties_on_entry"
    t.index ["key"], name: "index_properties_on_key"
  end

  create_table "relations", force: :cascade do |t|
    t.string "db1", null: false
    t.string "entry1", null: false
    t.string "db2", null: false
    t.string "entry2", null: false
    t.index ["db1"], name: "index_relations_on_db1"
    t.index ["db2"], name: "index_relations_on_db2"
    t.index ["entry1"], name: "index_relations_on_entry1"
    t.index ["entry2"], name: "index_relations_on_entry2"
  end

end
