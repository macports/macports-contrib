class PortDependency < ActiveRecord::Base
  belongs_to :port
  belongs_to :dependency, :class_name => "Port"
end
