class InstalledPortsController < ApplicationController
    
  def index
    @ports = InstalledPort.all
        
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @port = InstalledPort.find(params[:id])
  end
end