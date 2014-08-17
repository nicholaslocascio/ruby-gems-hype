# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140817051400) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "repos", force: true do |t|
    t.string   "name"
    t.string   "full_name"
    t.text     "description"
    t.integer  "stargazers_count"
    t.integer  "watchers_count"
    t.integer  "referenced_count"
    t.integer  "references_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repos", ["name"], name: "index_repos_on_name", unique: true, using: :btree

end
