class User < ActiveRecord::Base
  has_one  :os_statistic
  has_many :installed_ports
end
