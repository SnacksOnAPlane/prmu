require 'sqlite3'
require_relative '../cities'

@db = SQLite3::Database.new "prmu.db"

@db.execute <<-SQL
  create table cities (
    id INTEGER PRIMARY KEY,
    name TEXT
  );
SQL

CITIES.split("\n").each do |city|
  @db.execute("INSERT INTO cities (name) VALUES (?)", [ city ])
end
