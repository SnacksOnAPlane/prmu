require 'sqlite3'

db = SQLite3::Database.new "prmu.db"

db.execute <<-SQL
  create table posts (
    message TEXT,
    id TEXT PRIMARY KEY,
    updated_time DATETIME
  );
SQL
