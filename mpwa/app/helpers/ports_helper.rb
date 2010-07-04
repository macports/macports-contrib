module PortsHelper
  def print_search_links(port, member)
    links = String.new
    vals = port[member.to_sym]
    unless vals.nil?
      vals.split(" ").each do |val|
        links += "#{link_to val, search_path(member, val)} "
      end
      return links
    else
      return nil
    end
  end
end
