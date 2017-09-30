require 'date'

class PostService
  def do_work
    # TODO: get actual posts
    test_post = { fb_id: "153188931945861_214242015840552", message: "I'm saying this thing!", posted_at: "2017-09-30T16:00:37+0000" }
    write_post(test_post)
  end

  def write_post(post)
    post[:created_at] = post[:updated_at] = DateTime.now
    Insert.new('posts', post).execute
  end

  def upsert_post
    # TODO
  end
end
