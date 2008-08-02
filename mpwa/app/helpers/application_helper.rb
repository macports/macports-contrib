# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
    def email_obfuscate(str)
        if str =~ /(.+)@(.+)/
          localname = $1
          domain = $2
          if domain =~ /macports.org/i
            str = localname
          else
            str = "#{domain}:#{localname}"
          end
        end
        return str
    end
    
end
