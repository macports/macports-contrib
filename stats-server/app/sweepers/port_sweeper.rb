class PortSweeper < ActionController::Caching::Sweeper
  observe Port

  def after_create(port)
    expire_cache_for port
  end

  def after_update(port)
    expire_cache_for port
  end

  def after_destroy(port)
    expire_cache_for port
  end

private
  def expire_cache_for(port)
    expire_page category_ports_path(port.category)
    expire_page category_port_path(port.category, port)
  end
end