class PostDeleteWorker
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find_by(id: post_id)
    if post && post.created_at < 24.hours.ago
      puts("deleting post #{post.title}")
      post.destroy
    end
  end
end
