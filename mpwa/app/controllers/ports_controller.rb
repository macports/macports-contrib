class PortsController < ApplicationController
  def index
    unless params[:category_id].nil?
      @ports = Category.find(params[:category_id]).ports.paginate :page => params[:page], :order => 'name ASC', :per_page => 50
    else
      @ports = Port.paginate :page => params[:page], :order => 'name ASC', :per_page => 50
    end
    @page = params[:page] || 1

    respond_to do |format|
      format.html
    end
  end

  def show
    @port = Category.find(params[:category_id]).ports.find(params[:id])
    @comment = @port.comments.build

    respond_to do |format|
      format.html
    end
  end

  def search
    @ports = Port.search(params[:criteria], params[:val], params[:page])
    @page = params[:page] || 1

    respond_to do |format|
      format.html { render :action => :index }
    end
  end

  def search_generate
    redirect_to "/ports/search/#{params[:criteria]}/#{params[:val]}"
  end
end
