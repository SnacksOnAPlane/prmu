require 'pg'

class Query
  attr_accessor :table
  attr_accessor :query

  def initialize(table, params)
    self.table = table
    self.query = build_query(params)
  end

  def execute
    conn = PG.connect( dbname: 'prmu', user: 'prmu_user', password: 'prmu_pass' )
    conn.exec(self.query) do |result|
      puts result
    end
  end
end

class Insert < Query
  def build_query(object)
    validate(object)
    "INSERT INTO #{ self.table } (#{ object.keys.join(',') }) " \
    "VALUES (#{ object.values.map { |val| "'#{val}'" }.join(',') });"
  end

  def validate(object)
    object.each { |k, v| object[k] = v.to_s.gsub(/'/, "''") }
  end
end

class BulkInsert < Query
  def build_query(objects)
    validate(objects)
    "INSERT INTO #{ self.table } (#{ objects[0].keys.join(',') }) " \
    "VALUES #{ objects.map { |object| "(#{ object.values.map { |val| "'#{val}'" }.join(',') })" }.join(',') };"
  end

  def validate(objects)
    objects.map do |object|
      object.each { |k, v| object[k] = v.to_s.gsub(/'/, "''") }
    end
  end
end
