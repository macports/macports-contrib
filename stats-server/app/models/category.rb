class Category < ActiveRecord::Base
  has_many :ports
  
  validates_presence_of :name
end
