require 'comment'
require 'person'
require 'port_pkg'
require 'tag'

class Port < ActiveRecord::Base
    has_many :port_pkgs, :dependent => :destroy
    has_and_belongs_to_many :tags
    has_and_belongs_to_many :maintainers, :class_name => 'Person', :join_table => 'maintainers_ports' 
    has_and_belongs_to_many :comments
    
    def Port.ensure_port(name, meta)
        port = Port.find_by_name(name)
        if port.nil?
            # build a new port using default values
            port = Port.new
            
            port.name = name
            port.short_desc = meta.short_desc
            port.long_desc = meta.long_desc
            port.home_page = meta.home_page
            
            # Save before we tag
            port.save
            
            meta.maintainers.each do |maintainer|
                person = Person.ensure_person_with_email(maintainer)
                port.maintainers << person
            end
             
            meta.categories.each { |c| port.add_tag c }

            # Save the port
            port.save
        end
        return port
    end
    
    def Port.build_query_conditions(q)
      "name like '%#{sanitize_sql(q)}%'"
    end
    
    def add_tag(name)
      tag = Tag.find_or_create_by_name(name)
      self.tags << tag unless self.tags.include?(tag)
    end
    
    def remove_tag(name)
        self.tags.select { |t| t.name == name }.each { |t| self.tags.delete(t) }
    end
    
    def <=>(other)
        self.name <=> other.name
    end
    
end
