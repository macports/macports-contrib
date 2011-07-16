class Submission < ActiveRecord::Base
  
  # Populate an OsStatistics row based on submitted JSON data
  def add_os_data(user, os)
    logger.debug "In add_os_data"
    
    if os.nil?
      return
    end
    
    macports_version = os['macports_version']
    osx_version      = os['osx_version']
    os_arch          = os['os_arch']
    os_platform      = os['os_platform']
    build_arch       = os['build_arch']
    gcc_version      = os['gcc_version']
    xcode_version    = os['xcode_version']
   
    # Try to find an existing entry
    os_stats = OsStatistic.find_by_user_id(user.id)
     
    if os_stats.nil?
      # No entry for this user - create a new one
      os_stats = OsStatistic.new()
    end
    
    os_stats[:user_id]          = user.id
    os_stats[:macports_version] = macports_version
    os_stats[:osx_version]      = osx_version
    os_stats[:os_arch]          = os_arch
    os_stats[:os_platform]      = os_platform
    os_stats[:build_arch]       = build_arch
    os_stats[:gcc_version]      = gcc_version
    os_stats[:xcode_version]    = xcode_version
    
    if not os_stats.save
      logger.debug "Unable to save os_stats"
      logger.debug "Error message: #{os_stats.errors.full_messages}"
    end
  end

  def add_port(user, macports_port, installed_port, month, year)
    logger.debug {"Adding installed port #{installed_port['name']}"}
    
    # Update any ports found for this user is they have already been submitted this month
    port_entry = InstalledPort.find_by_port_id_and_user_id_and_month_and_year(macports_port.id, 
                                                                              user.id, 
                                                                              month, 
                                                                              year)
    
    # New port entry                  
    if port_entry.nil?
      port_entry = InstalledPort.new
    end
        
    port_entry[:user_id]  = user.id
    port_entry[:port_id]  = macports_port.id
    port_entry[:version]  = installed_port['version']
    port_entry[:variants] = installed_port['variants']
    port_entry[:month]    = month
    port_entry[:year]     = year
                              
    if not port_entry.save
     logger.debug "Unable to save port #{installed_port['name']}"
     logger.debug "Reason: #{port_entry.errors.full_messages}"
   end
 end

  def add_installed_ports(uuid, installed_ports)
    logger.debug "In add_installed_ports"
    
    if installed_ports.nil?
      return
    end
    
    current_time = Time.now
    month = current_time.month
    year = current_time.year
    
    installed_ports.each do |installed_port|
      # Find the reported port in the MacPorts repository
      macports_port = Port.find_by_name(installed_port['name'])

      if macports_port.nil?
        logger.debug {"Skipping unknown port #{installed_port['name']} - Not in MacPorts repository"}
        next
      end
      
      # Update installed port information
      add_port(uuid, macports_port, installed_port, month, year)
    end
  end
  
  def save_data
    json = ActiveSupport::JSON.decode(data) 
    os = json['os']
    active_ports = json['active_ports']
    #inactive_ports = json['inactive_ports']
    
    user = User.find_or_create_by_uuid(json['id'])
    
    add_os_data(user, os)
    add_installed_ports(user, active_ports)
  end
end
