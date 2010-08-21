class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  def after_create(comment)
    expire_cache_for comment
  end

private
  def expire_cache_for(comment)
    expire_page category_port_path(comment.port.category, comment.port)
  end
end