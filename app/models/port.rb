class Port < ActiveRecord::Base
  has_many :port_dependencies
  has_many :dependencies, :through => :port_dependencies
  has_many :comments
  has_one :category
  has_many :supplimental_categories
  belongs_to :category
end
