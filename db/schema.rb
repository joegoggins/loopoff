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

ActiveRecord::Schema.define(:version => 20100614165542) do

  create_table "directories", :force => true do |t|
    t.string   "slug"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "playlist_cells", :force => true do |t|
    t.integer  "playlist_row_id"
    t.string   "blob_id"
    t.string   "commit_id"
    t.string   "loopoff_db"
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "playlist_rows", :force => true do |t|
    t.integer  "playlist_id"
    t.string   "aggregation_string"
    t.string   "commit_id"
    t.string   "loopoff_db"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "playlists", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
