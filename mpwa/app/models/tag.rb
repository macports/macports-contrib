require 'port'
require 'port_pkg'

class Tag < ActiveRecord::Base
    has_and_belongs_to_many :ports
    has_and_belongs_to_many :port_pkgs

    def <=>(other)
        self.name <=> other.name
    end
end
