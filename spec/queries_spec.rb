require 'spec_helper'
require_relative '../bin/queries'

context 'Insert' do
  it 'should return valid query given a single record' do
    params = { key1: 'val1', key2: 'val2' }
    expect(Insert.new('posts', params).query).to eq "INSERT INTO posts (key1,key2) VALUES ('val1','val2');"
  end

  it 'should validate params with single quotes' do
    params = { key1: "I'm tricky" }
    expect(Insert.new('posts', params).query).to eq "INSERT INTO posts (key1) VALUES ('I''m tricky');"
  end
end

context 'BulkInsert' do
  it 'should return valid query given multiple records' do
    params = [{ key1: 'val1', key2: 'val2' }, { key1: 'val3', key2: 'val4' }]
    expect(BulkInsert.new('posts', params).query).to eq "INSERT INTO posts (key1,key2) VALUES ('val1','val2'),('val3','val4');"
  end

  it 'should validate params with single quotes' do
    params = [{ key1: "I'm tricky" }, { key1: "'thingy'" }]
    expect(BulkInsert.new('posts', params).query).to eq "INSERT INTO posts (key1) VALUES ('I''m tricky'),('''thingy''');"
  end
end