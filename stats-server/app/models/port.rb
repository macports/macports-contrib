class Port < ActiveRecord::Base
  has_one :category
  belongs_to :category
  has_many :installed_ports


  validates_presence_of :name, :version

  def self.search(criteria, val, page)
    paginate :per_page => 50, :page => page, :conditions => ["#{self.columns_hash[criteria].name} like ?", "%#{val}%"], :order => 'name ASC'
  end
end
