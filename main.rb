Dir[File.dirname(__FILE__) + '/bin/*.rb'].each {|file| require file }

PostService.new.do_work