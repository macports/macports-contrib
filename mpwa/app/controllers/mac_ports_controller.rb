class MacPortsController < ApplicationController
    def index
      @recent_pkgs = PortPkg.find(:all, :order => 'submitted_at desc', :limit => 25)
      render :action => 'show'
    end
end
