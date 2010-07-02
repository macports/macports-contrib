class PortsController < ApplicationController
  def index
    @ports = Port.paginate :page => params[:page], :order => 'name ASC', :per_page => 50
    @updated = Port.all(:order => 'updated_at DESC', :limit => 1).first.updated_at

    respond_to do |format|
      format.html
    end
  end

  def show
    @port = Port.find(params[:id])
    @comment = @port.comments.build

    respond_to do |format|
      format.html
    end
  end
end
