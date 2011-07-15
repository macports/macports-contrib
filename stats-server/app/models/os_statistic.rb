class OsStatistic < ActiveRecord::Base
  belongs_to :user
  
  attr_accessible :user_id
  attr_accessible :macports_version
  attr_accessible :osx_version
  attr_accessible :os_arch
  attr_accessible :os_platform
  attr_accessible :build_arch
  attr_accessible :gcc_version
  attr_accessible :xcode_version
  
  validates :user_id,           :presence => true
  validates :macports_version,  :presence => true
  validates :osx_version,       :presence => true
  validates :os_arch,           :presence => true
  validates :os_platform,       :presence => true
  validates :build_arch,        :presence => true
  validates :gcc_version,       :presence => true
  validates :xcode_version,     :presence => true

end
