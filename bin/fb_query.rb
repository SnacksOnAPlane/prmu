require 'koala'
require 'pry'
require 'sqlite3'
require_relative "../creds.rb"

@db = SQLite3::Database.new "prmu.db"
@graph = Koala::Facebook::API.new(FB_API_KEY)


def get_newest_post_time
  last_time = nil
  @db.execute("SELECT * FROM posts ORDER BY updated_time desc LIMIT 1") do |row|
    binding.pry
  end
  last_time
end

def insert_into_db(post)
  @db.execute("INSERT INTO posts (message, id, updated_time) VALUES (?, ?, ?)",
              [ post['message'], post['id'], post['updated_time'] ])
end

def get_posts_since(post_time)
  # TODO: add 'since' parameter for post_time
  data = @graph.get_object("153188931945861/feed")
  data.each { |p| yield p }
end

get_posts_since(get_newest_post_time) do |post|
  insert_into_db(post)
end

# stick the data into the SQLite db

binding.pry
