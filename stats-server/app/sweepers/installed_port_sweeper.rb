class InstalledPortSweeper < ActionController::Caching::Sweeper
	observe InstalledPort

	def after_create(installedport)
		expire_cache_for installedport.port
	end

	def after_update(installedport)
		expire_cache_for installedport.port
	end

	def after_destroy(installedport)
		expire_cache_for installedport.port
	end

	private
	def expire_cache_for(port)
		logger.debug "Expiring cache for #{port.category}/#{port.name}"
		expire_page category_port_path(port.category, port)
	end
end
