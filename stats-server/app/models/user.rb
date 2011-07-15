class User < ActiveRecord::Base
  has_one  :os_statistics
  has_many :installed_ports
end
