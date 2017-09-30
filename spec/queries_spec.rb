require 'spec_helper'
require_relative '../bin/queries'

context 'Insert' do
  it 'return valid query given a single record' do
    params = { key1: :val1, key2: :val2 }
    expect(Insert.new('posts', params).query).to eq "INSERT INTO posts (key1,key2) VALUES (val1,val2);"
  end
end