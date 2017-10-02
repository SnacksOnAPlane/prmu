require 'koala'
require 'pry'
require_relative "../creds.rb"

@graph = Koala::Facebook::API.new(FB_API_KEY)

data = @graph.get_object("153188931945861/feed")
binding.pry
