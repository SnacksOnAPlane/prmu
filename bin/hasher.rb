require 'sqlite3'
require 'digest'

UPDATE_DB = false

@db = SQLite3::Database.new "prmu.db"

if UPDATE_DB
	@db.execute "ALTER TABLE posts ADD COLUMN message_hash TEXT"
end

ids_to_md5s = {}

@db.execute("SELECT id, message FROM posts WHERE message IS NOT NULL") do |id, message|
	md5 = Digest::MD5.hexdigest message
	ids_to_md5s[id] = md5
end

total = ids_to_md5s.keys.length

i = 0

ids_to_md5s.keys.each do |id|
	i += 1
	puts "#{i}/#{total}" if i % 100 == 0
	md5 = ids_to_md5s[id]
	@db.execute("UPDATE posts SET message_hash = ? WHERE id = ?", [md5, id])
end
