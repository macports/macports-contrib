class Variant < ActiveRecord::Base
    belongs_to :port_pkg
    
    def <=>(other)
        self.name <=> other.name
    end
    
end
