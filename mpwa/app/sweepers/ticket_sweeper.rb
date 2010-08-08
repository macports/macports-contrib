class PortSweeper < ActionController::Caching::Sweeper
  observe Ticket

  def after_create(ticket)
    expire_cache_for ticket.port
  end

  def after_update(ticket)
    expire_cache_for ticket.port
  end

  def after_destroy(ticket)
    expire_cache_for ticket.port
  end

private
  def expire_cache_for(ticket)
    expire_page :controller => :port, :action => :index
    expire_page :controller => :port, :action => :show
  end
end