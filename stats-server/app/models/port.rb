class Port < ActiveRecord::Base
  has_one :category
  belongs_to :category

  def self.search(criteria, val, page)
    paginate :per_page => 50, :page => page, :conditions => ["#{self.columns_hash[criteria].name} like ?", "%#{val}%"], :order => 'name ASC'
  end
end
