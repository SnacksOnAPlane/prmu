class Query
  attr_accessor :table
  attr_accessor :query

  def initialize(table, params)
    self.table = table
    self.query = build_query(params)
  end

  def self.execute
    conn = PG.connect( dbname: 'prmu', user: 'prmu', password: 'prmu_pass' )
    conn.exec(self.query) do |result|
      puts result
    end
  end
end

class Insert < Query
  def build_query(post)
    "INSERT INTO #{ self.table } (#{ post.keys.join(',') }) " \
    "VALUES (#{ post.values.join(',') });"
  end
end

class BulkInsert < Query
  def build_query(posts)
    "INSERT INTO #{ self.table } (#{ posts[0].keys.join(',') }) " \
    "VALUES #{ posts.map { |post| "(#{ post.values.join(',') })" }.join(',') };"
  end
end
