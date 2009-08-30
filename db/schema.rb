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

ActiveRecord::Schema.define(:version => 20090830080519) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.string   "linkages_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "linkages", :force => true do |t|
    t.integer  "link_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "domain_id"
  end

  create_table "links", :force => true do |t|
    t.string   "url"
    t.integer  "linkages_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "domain_name"
    t.text     "page_title"
    t.text     "page_excerpt"
    t.string   "page_type"
    t.string   "image_url"
    t.integer  "domain_id"
    t.boolean  "followed",       :default => false
  end

  create_table "short_links", :force => true do |t|
    t.integer  "link_id"
    t.string   "url"
    t.boolean  "inactive",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "twitter_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "twitter_followers_count"
    t.integer  "twitter_friends_count"
    t.datetime "last_searched"
    t.boolean  "loading"
  end

end
