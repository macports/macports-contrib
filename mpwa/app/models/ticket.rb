class Ticket < ActiveRecord::Base
  belongs_to :port

  validates_presence_of :port_id
  validates_presence_of :ticket
end
