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

ActiveRecord::Schema.define(version: 2022_03_02_120617) do

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
    t.index ["entry1", "db1", "db2"], name: "index_relations_on_entry1_and_db1_and_db2"
    t.index ["entry2", "db2", "db1"], name: "index_relations_on_entry2_and_db2_and_db1"
  end

  create_table "table1", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table1_on_classification"
    t.index ["leaf"], name: "index_table1_on_leaf"
    t.index ["lft"], name: "index_table1_on_lft"
    t.index ["parent_id"], name: "index_table1_on_parent_id"
    t.index ["rgt"], name: "index_table1_on_rgt"
  end

  create_table "table10", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table10_on_classification"
    t.index ["leaf"], name: "index_table10_on_leaf"
    t.index ["lft"], name: "index_table10_on_lft"
    t.index ["parent_id"], name: "index_table10_on_parent_id"
    t.index ["rgt"], name: "index_table10_on_rgt"
  end

  create_table "table11", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_table11_on_distribution"
    t.index ["distribution_value"], name: "index_table11_on_distribution_value"
  end

  create_table "table12", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table12_on_classification"
    t.index ["leaf"], name: "index_table12_on_leaf"
    t.index ["lft"], name: "index_table12_on_lft"
    t.index ["parent_id"], name: "index_table12_on_parent_id"
    t.index ["rgt"], name: "index_table12_on_rgt"
  end

  create_table "table13", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_table13_on_distribution"
    t.index ["distribution_value"], name: "index_table13_on_distribution_value"
  end

  create_table "table14", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_table14_on_distribution"
    t.index ["distribution_value"], name: "index_table14_on_distribution_value"
  end

  create_table "table15", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_table15_on_distribution"
    t.index ["distribution_value"], name: "index_table15_on_distribution_value"
  end

  create_table "table16", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table16_on_classification"
    t.index ["leaf"], name: "index_table16_on_leaf"
    t.index ["lft"], name: "index_table16_on_lft"
    t.index ["parent_id"], name: "index_table16_on_parent_id"
    t.index ["rgt"], name: "index_table16_on_rgt"
  end

  create_table "table17", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table17_on_classification"
    t.index ["leaf"], name: "index_table17_on_leaf"
    t.index ["lft"], name: "index_table17_on_lft"
    t.index ["parent_id"], name: "index_table17_on_parent_id"
    t.index ["rgt"], name: "index_table17_on_rgt"
  end

  create_table "table18", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table18_on_classification"
    t.index ["leaf"], name: "index_table18_on_leaf"
    t.index ["lft"], name: "index_table18_on_lft"
    t.index ["parent_id"], name: "index_table18_on_parent_id"
    t.index ["rgt"], name: "index_table18_on_rgt"
  end

  create_table "table19", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table19_on_classification"
    t.index ["leaf"], name: "index_table19_on_leaf"
    t.index ["lft"], name: "index_table19_on_lft"
    t.index ["parent_id"], name: "index_table19_on_parent_id"
    t.index ["rgt"], name: "index_table19_on_rgt"
  end

  create_table "table2", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table2_on_classification"
    t.index ["leaf"], name: "index_table2_on_leaf"
    t.index ["lft"], name: "index_table2_on_lft"
    t.index ["parent_id"], name: "index_table2_on_parent_id"
    t.index ["rgt"], name: "index_table2_on_rgt"
  end

  create_table "table20", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table20_on_classification"
    t.index ["leaf"], name: "index_table20_on_leaf"
    t.index ["lft"], name: "index_table20_on_lft"
    t.index ["parent_id"], name: "index_table20_on_parent_id"
    t.index ["rgt"], name: "index_table20_on_rgt"
  end

  create_table "table21", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table21_on_classification"
    t.index ["leaf"], name: "index_table21_on_leaf"
    t.index ["lft"], name: "index_table21_on_lft"
    t.index ["parent_id"], name: "index_table21_on_parent_id"
    t.index ["rgt"], name: "index_table21_on_rgt"
  end

  create_table "table22", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_table22_on_distribution"
    t.index ["distribution_value"], name: "index_table22_on_distribution_value"
  end

  create_table "table23", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table23_on_classification"
    t.index ["leaf"], name: "index_table23_on_leaf"
    t.index ["lft"], name: "index_table23_on_lft"
    t.index ["parent_id"], name: "index_table23_on_parent_id"
    t.index ["rgt"], name: "index_table23_on_rgt"
  end

  create_table "table24", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table24_on_classification"
    t.index ["leaf"], name: "index_table24_on_leaf"
    t.index ["lft"], name: "index_table24_on_lft"
    t.index ["parent_id"], name: "index_table24_on_parent_id"
    t.index ["rgt"], name: "index_table24_on_rgt"
  end

  create_table "table25", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table25_on_classification"
    t.index ["leaf"], name: "index_table25_on_leaf"
    t.index ["lft"], name: "index_table25_on_lft"
    t.index ["parent_id"], name: "index_table25_on_parent_id"
    t.index ["rgt"], name: "index_table25_on_rgt"
  end

  create_table "table26", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table26_on_classification"
    t.index ["leaf"], name: "index_table26_on_leaf"
    t.index ["lft"], name: "index_table26_on_lft"
    t.index ["parent_id"], name: "index_table26_on_parent_id"
    t.index ["rgt"], name: "index_table26_on_rgt"
  end

  create_table "table27", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table27_on_classification"
    t.index ["leaf"], name: "index_table27_on_leaf"
    t.index ["lft"], name: "index_table27_on_lft"
    t.index ["parent_id"], name: "index_table27_on_parent_id"
    t.index ["rgt"], name: "index_table27_on_rgt"
  end

  create_table "table28", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table28_on_classification"
    t.index ["leaf"], name: "index_table28_on_leaf"
    t.index ["lft"], name: "index_table28_on_lft"
    t.index ["parent_id"], name: "index_table28_on_parent_id"
    t.index ["rgt"], name: "index_table28_on_rgt"
  end

  create_table "table29", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table29_on_classification"
    t.index ["leaf"], name: "index_table29_on_leaf"
    t.index ["lft"], name: "index_table29_on_lft"
    t.index ["parent_id"], name: "index_table29_on_parent_id"
    t.index ["rgt"], name: "index_table29_on_rgt"
  end

  create_table "table3", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table3_on_classification"
    t.index ["leaf"], name: "index_table3_on_leaf"
    t.index ["lft"], name: "index_table3_on_lft"
    t.index ["parent_id"], name: "index_table3_on_parent_id"
    t.index ["rgt"], name: "index_table3_on_rgt"
  end

  create_table "table30", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table30_on_classification"
    t.index ["leaf"], name: "index_table30_on_leaf"
    t.index ["lft"], name: "index_table30_on_lft"
    t.index ["parent_id"], name: "index_table30_on_parent_id"
    t.index ["rgt"], name: "index_table30_on_rgt"
  end

  create_table "table31", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table31_on_classification"
    t.index ["leaf"], name: "index_table31_on_leaf"
    t.index ["lft"], name: "index_table31_on_lft"
    t.index ["parent_id"], name: "index_table31_on_parent_id"
    t.index ["rgt"], name: "index_table31_on_rgt"
  end

  create_table "table32", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table32_on_classification"
    t.index ["leaf"], name: "index_table32_on_leaf"
    t.index ["lft"], name: "index_table32_on_lft"
    t.index ["parent_id"], name: "index_table32_on_parent_id"
    t.index ["rgt"], name: "index_table32_on_rgt"
  end

  create_table "table33", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table33_on_classification"
    t.index ["leaf"], name: "index_table33_on_leaf"
    t.index ["lft"], name: "index_table33_on_lft"
    t.index ["parent_id"], name: "index_table33_on_parent_id"
    t.index ["rgt"], name: "index_table33_on_rgt"
  end

  create_table "table34", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_table34_on_distribution"
    t.index ["distribution_value"], name: "index_table34_on_distribution_value"
  end

  create_table "table35", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table35_on_classification"
    t.index ["leaf"], name: "index_table35_on_leaf"
    t.index ["lft"], name: "index_table35_on_lft"
    t.index ["parent_id"], name: "index_table35_on_parent_id"
    t.index ["rgt"], name: "index_table35_on_rgt"
  end

  create_table "table36", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table36_on_classification"
    t.index ["leaf"], name: "index_table36_on_leaf"
    t.index ["lft"], name: "index_table36_on_lft"
    t.index ["parent_id"], name: "index_table36_on_parent_id"
    t.index ["rgt"], name: "index_table36_on_rgt"
  end

  create_table "table37", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table37_on_classification"
    t.index ["leaf"], name: "index_table37_on_leaf"
    t.index ["lft"], name: "index_table37_on_lft"
    t.index ["parent_id"], name: "index_table37_on_parent_id"
    t.index ["rgt"], name: "index_table37_on_rgt"
  end

  create_table "table38", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table38_on_classification"
    t.index ["leaf"], name: "index_table38_on_leaf"
    t.index ["lft"], name: "index_table38_on_lft"
    t.index ["parent_id"], name: "index_table38_on_parent_id"
    t.index ["rgt"], name: "index_table38_on_rgt"
  end

  create_table "table39", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table39_on_classification"
    t.index ["leaf"], name: "index_table39_on_leaf"
    t.index ["lft"], name: "index_table39_on_lft"
    t.index ["parent_id"], name: "index_table39_on_parent_id"
    t.index ["rgt"], name: "index_table39_on_rgt"
  end

  create_table "table4", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table4_on_classification"
    t.index ["leaf"], name: "index_table4_on_leaf"
    t.index ["lft"], name: "index_table4_on_lft"
    t.index ["parent_id"], name: "index_table4_on_parent_id"
    t.index ["rgt"], name: "index_table4_on_rgt"
  end

  create_table "table40", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table40_on_classification"
    t.index ["leaf"], name: "index_table40_on_leaf"
    t.index ["lft"], name: "index_table40_on_lft"
    t.index ["parent_id"], name: "index_table40_on_parent_id"
    t.index ["rgt"], name: "index_table40_on_rgt"
  end

  create_table "table41", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table41_on_classification"
    t.index ["leaf"], name: "index_table41_on_leaf"
    t.index ["lft"], name: "index_table41_on_lft"
    t.index ["parent_id"], name: "index_table41_on_parent_id"
    t.index ["rgt"], name: "index_table41_on_rgt"
  end

  create_table "table42", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table42_on_classification"
    t.index ["leaf"], name: "index_table42_on_leaf"
    t.index ["lft"], name: "index_table42_on_lft"
    t.index ["parent_id"], name: "index_table42_on_parent_id"
    t.index ["rgt"], name: "index_table42_on_rgt"
  end

  create_table "table43", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table43_on_classification"
    t.index ["leaf"], name: "index_table43_on_leaf"
    t.index ["lft"], name: "index_table43_on_lft"
    t.index ["parent_id"], name: "index_table43_on_parent_id"
    t.index ["rgt"], name: "index_table43_on_rgt"
  end

  create_table "table44", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_table44_on_distribution"
    t.index ["distribution_value"], name: "index_table44_on_distribution_value"
  end

  create_table "table45", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_table45_on_distribution"
    t.index ["distribution_value"], name: "index_table45_on_distribution_value"
  end

  create_table "table46", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table46_on_classification"
    t.index ["leaf"], name: "index_table46_on_leaf"
    t.index ["lft"], name: "index_table46_on_lft"
    t.index ["parent_id"], name: "index_table46_on_parent_id"
    t.index ["rgt"], name: "index_table46_on_rgt"
  end

  create_table "table47", force: :cascade do |t|
    t.string "distribution", null: false
    t.string "distribution_label"
    t.float "distribution_value", null: false
    t.string "bin_id"
    t.string "bin_label"
    t.index ["distribution"], name: "index_table47_on_distribution"
    t.index ["distribution_value"], name: "index_table47_on_distribution_value"
  end

  create_table "table48", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table48_on_classification"
    t.index ["leaf"], name: "index_table48_on_leaf"
    t.index ["lft"], name: "index_table48_on_lft"
    t.index ["parent_id"], name: "index_table48_on_parent_id"
    t.index ["rgt"], name: "index_table48_on_rgt"
  end

  create_table "table49", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table49_on_classification"
    t.index ["leaf"], name: "index_table49_on_leaf"
    t.index ["lft"], name: "index_table49_on_lft"
    t.index ["parent_id"], name: "index_table49_on_parent_id"
    t.index ["rgt"], name: "index_table49_on_rgt"
  end

  create_table "table5", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table5_on_classification"
    t.index ["leaf"], name: "index_table5_on_leaf"
    t.index ["lft"], name: "index_table5_on_lft"
    t.index ["parent_id"], name: "index_table5_on_parent_id"
    t.index ["rgt"], name: "index_table5_on_rgt"
  end

  create_table "table50", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table50_on_classification"
    t.index ["leaf"], name: "index_table50_on_leaf"
    t.index ["lft"], name: "index_table50_on_lft"
    t.index ["parent_id"], name: "index_table50_on_parent_id"
    t.index ["rgt"], name: "index_table50_on_rgt"
  end

  create_table "table51", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table51_on_classification"
    t.index ["leaf"], name: "index_table51_on_leaf"
    t.index ["lft"], name: "index_table51_on_lft"
    t.index ["parent_id"], name: "index_table51_on_parent_id"
    t.index ["rgt"], name: "index_table51_on_rgt"
  end

  create_table "table52", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table52_on_classification"
    t.index ["leaf"], name: "index_table52_on_leaf"
    t.index ["lft"], name: "index_table52_on_lft"
    t.index ["parent_id"], name: "index_table52_on_parent_id"
    t.index ["rgt"], name: "index_table52_on_rgt"
  end

  create_table "table53", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table53_on_classification"
    t.index ["leaf"], name: "index_table53_on_leaf"
    t.index ["lft"], name: "index_table53_on_lft"
    t.index ["parent_id"], name: "index_table53_on_parent_id"
    t.index ["rgt"], name: "index_table53_on_rgt"
  end

  create_table "table6", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table6_on_classification"
    t.index ["leaf"], name: "index_table6_on_leaf"
    t.index ["lft"], name: "index_table6_on_lft"
    t.index ["parent_id"], name: "index_table6_on_parent_id"
    t.index ["rgt"], name: "index_table6_on_rgt"
  end

  create_table "table7", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table7_on_classification"
    t.index ["leaf"], name: "index_table7_on_leaf"
    t.index ["lft"], name: "index_table7_on_lft"
    t.index ["parent_id"], name: "index_table7_on_parent_id"
    t.index ["rgt"], name: "index_table7_on_rgt"
  end

  create_table "table8", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table8_on_classification"
    t.index ["leaf"], name: "index_table8_on_leaf"
    t.index ["lft"], name: "index_table8_on_lft"
    t.index ["parent_id"], name: "index_table8_on_parent_id"
    t.index ["rgt"], name: "index_table8_on_rgt"
  end

  create_table "table9", force: :cascade do |t|
    t.string "classification", null: false
    t.string "classification_label"
    t.string "classification_parent"
    t.boolean "leaf"
    t.integer "parent_id"
    t.integer "lft", default: 0, null: false
    t.integer "rgt", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["classification"], name: "index_table9_on_classification"
    t.index ["leaf"], name: "index_table9_on_leaf"
    t.index ["lft"], name: "index_table9_on_lft"
    t.index ["parent_id"], name: "index_table9_on_parent_id"
    t.index ["rgt"], name: "index_table9_on_rgt"
  end

end
