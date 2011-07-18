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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110718213618) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "installed_ports", :force => true do |t|
    t.integer  "port_id"
    t.string   "version"
    t.text     "variants"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "installed_ports", ["port_id"], :name => "index_installed_ports_on_port_id"
  add_index "installed_ports", ["user_id"], :name => "index_installed_ports_on_user_id"

  create_table "os_statistics", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "macports_version"
    t.string   "osx_version"
    t.string   "os_arch"
    t.string   "os_platform"
    t.string   "build_arch"
    t.string   "xcode_version"
    t.string   "gcc_version"
    t.integer  "user_id"
  end

  add_index "os_statistics", ["user_id"], :name => "index_os_statistics_on_user_id"

  create_table "ports", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.string   "version"
    t.text     "description"
    t.string   "licenses"
    t.integer  "category_id"
    t.text     "variants"
    t.string   "maintainers"
    t.string   "platforms"
    t.string   "categories"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ports", ["name"], :name => "index_ports_on_name"

  create_table "submissions", :force => true do |t|
    t.string   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
