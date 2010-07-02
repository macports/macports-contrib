# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100702053149) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "port_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "port_dependencies", :force => true do |t|
    t.integer  "port_id"
    t.integer  "dependency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ports", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.string   "version"
    t.text     "description"
    t.string   "licenses"
    t.integer  "category_id", :limit => 255
    t.string   "variants"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "maintainers"
    t.string   "platforms"
  end

  create_table "supplemental_categories", :force => true do |t|
    t.string   "name"
    t.integer  "port_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
