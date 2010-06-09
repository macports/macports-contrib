class Port < ActiveRecord::Base
  has_many :port_dependencies
  has_many :dependencies, :through => :port_dependencies
  has_many :comments
end
