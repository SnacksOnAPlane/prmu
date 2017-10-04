require 'koala'
require 'pry'
require 'sqlite3'
require 'digest'
require_relative './populate_sheet'
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
  digest = post['message'] ? Digest::MD5.hexdigest(post['message']) : nil
  @db.execute("INSERT INTO posts (message, id, updated_time, message_hash) VALUES (?, ?, ?, ?)",
              [ post['message'], post['id'], post['updated_time'], digest ])
end

def get_posts_since(post_time)
  # TODO: add 'since' parameter for post_time
  data = @graph.get_object("153188931945861/feed", since: post_time, limit: 100)
  while data.length > 0
    puts "inserting #{data.length} records (#{data.first['updated_time']} - #{data.last['updated_time']})"
    data.each { |p| yield p }
    data = data.next_page
  end
end

def get_cities
  cities = []
  @db.execute("SELECT name, id FROM cities") { |c| cities.push(c) }
  cities
end

def each_post
  @db.execute("SELECT message, id FROM posts") { |p| yield p }
end

def associate_post(post_id, city_id)
  @db.execute("INSERT INTO city_posts (city_id, post_id) VALUES (?,?)", [city_id, post_id])
end

@cities = get_cities

def associate_with_cities(post)
  @cities.each do |city_name, city_id|
    if post['message'] && post['message'].downcase.include?(city_name.downcase)
      associate_post(post['id'], city_id)
    end
  end
end

newest_post_time = get_newest_post_time
get_posts_since(newest_post_time) do |post|
  begin
    insert_into_db(post)
    associate_with_cities(post)
  rescue SQLite3::ConstraintException
    puts "skipping comment"
  end
end
populate_sheet_since(newest_post_time)
