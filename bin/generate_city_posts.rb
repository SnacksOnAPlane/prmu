require 'sqlite3'
require 'i18n'

I18n.available_locales = [:en]

CREATE = false

@db = SQLite3::Database.new "prmu.db"

if CREATE
  @db.execute <<-SQL
    create table city_posts (
      city_id INT,
      post_id TEXT,
      UNIQUE(city_id, post_id)
    );
  SQL
end

def get_cities
  cities = []
  @db.execute("SELECT name, id FROM cities") { |c| cities.push(c) }
  cities
end

def each_post
  @db.execute("SELECT message, id FROM posts ORDER BY updated_time DESC") { |p| yield p }
end

def associate_post(post_id, city_id)
  @db.execute("INSERT INTO city_posts (city_id, post_id) VALUES (?,?)", [city_id, post_id])
end

i = 0
cities = get_cities
each_post do |message, post_id|
  i += 1
  puts "post #{i}"
  cities.each do |city_name, city_id|
    city_name = I18n.transliterate(city_name.downcase)
    if message && I18n.transliterate(message.downcase).include?(city_name)
      associate_post(post_id, city_id)
    end
  end
end
