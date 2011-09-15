class Submission < ActiveRecord::Base
    
  def save_data
    json = ActiveSupport::JSON.decode(data) 
    os = json['os']
    active_ports = json['active_ports']
    #inactive_ports = json['inactive_ports']
    
    user = User.find_or_create_by_uuid(json['id'])
    
    OsStatistic.add_os_data(user, os)
    InstalledPort.add_installed_ports(user, active_ports)
  end
  
end
