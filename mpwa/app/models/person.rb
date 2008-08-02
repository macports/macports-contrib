require 'port'
require 'port_pkg'

class Person < ActiveRecord::Base
    has_and_belongs_to_many :ports, :class_name => 'Port', :join_table => 'maintainers_ports'
    has_many :port_pkgs, :foreign_key => 'submitter_id'

    def Person.ensure_person_with_email(email, name = nil)
        person = Person.find_by_email(email)
        if person.nil?
            # build a new person using the supplied email address
            person = Person.new
            
            # Give it everything we know
            person.user_name = name.nil? || name.empty? ? email : name
            person.email = email
            
            # Save the person
            person.save
        end
        
        return person
    end
end
