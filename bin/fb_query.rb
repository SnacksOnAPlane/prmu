require 'koala'
require 'pry'
require 'sqlite3'
require 'digest'
require_relative "../creds.rb"

@db = SQLite3::Database.new "prmu.db"
@graph = Koala::Facebook::API.new(FB_API_KEY)


def get_newest_post_time
  last_time = nil
  @db.execute("SELECT * FROM posts ORDER BY updated_time desc LIMIT 1") do |row|
    last_time = DateTime.parse(row[2])
  end
  last_time
end

def insert_into_db(post)
  @db.execute("INSERT INTO posts (message, id, updated_time, message_hash) VALUES (?, ?, ?, ?)",
              [ post['message'], post['id'], post['updated_time'], Digest::MD5.hexdigest(post['message']) ])
end

def get_posts_since(post_time)
  # TODO: add 'since' parameter for post_time
  data = @graph.get_object("153188931945861/feed", since: post_time, limit: 100)
  while data.length
    puts "inserting #{data.length} records (#{data.first['updated_time']} - #{data.last['updated_time']})"
    data.each { |p| yield p }
    data = data.next_page
  end
end

get_posts_since(get_newest_post_time) do |post|
  begin
    insert_into_db(post)
  rescue SQLite3::ConstraintException
    puts "hit dupe; skipping"
  end
end
