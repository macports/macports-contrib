class PortSweeper < ActionController::Caching::Sweeper
  observe Ticket

  def after_create(ticket)
    expire_cache_for ticket
  end

  def after_update(ticket)
    expire_cache_for ticket
  end

  def after_destroy(ticket)
    expire_cache_for ticket
  end

private
  def expire_cache_for(ticket)
    expire_page category_port_path(ticket.port.category, ticket.port)
  end
end