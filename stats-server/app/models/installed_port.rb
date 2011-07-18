class InstalledPort < ActiveRecord::Base
  belongs_to :port
  has_one    :user
  
  validates_presence_of :user_id, :port_id, :version
end
