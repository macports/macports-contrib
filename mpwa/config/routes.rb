ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Pretty urls
  # ===========
  # portpkg submittion
  map.portpkgsubmit 'submit', :controller => 'port_pkg', :action => 'submit'
  
  # portpkg by pkgid
  map.portpkg 'portpkg/:id', :controller => 'port_pkg', :action => 'emit_portpkg', :id => /\d+/
  
  # portpkg file by pkgid
  map.connect 'portpkg/:id/*path', :controller => 'port_pkg', :action => 'emit_portpkg_path', :id => /\d+/

  # portpkg by named selector (unimplemented)
  map.connect 'portpkg/:selector/:portname', :controller => 'port_pkg', :action => 'byselector'

  # Pretty 

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id', :controller => 'mac_ports'
end
