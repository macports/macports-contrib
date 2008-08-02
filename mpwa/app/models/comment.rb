require 'person'
require 'port'
require 'port_pkg'

class Comment < ActiveRecord::Base
  belongs_to :commenter, :class_name => 'Person', :foreign_key => 'commenter_id'
  has_and_belongs_to_many :ports
  has_and_belongs_to_many :port_pkgs

  def <=>(other)
    self.comment_at <=> other.comment_at
  end
end
