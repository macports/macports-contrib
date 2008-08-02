class PortController < ApplicationController
    
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @port_pages, @ports = paginate :ports, :per_page => 80, :order => 'name'
  end

  def show
    @port = Port.find(params[:id])
  end

  def random
    @port = Port.find(:first, :order => "rand()")
    redirect_to :action => 'show', :id => @port
  end
  
  def new
    @port = Port.new
  end

  def create
    @port = Port.new(params[:port])
    if @port.save
      flash[:notice] = 'Port was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @port = Port.find(params[:id])
  end

  def update
    @port = Port.find(params[:id])
    if @port.update_attributes(params[:port])
      flash[:notice] = 'Port was successfully updated.'
      redirect_to :action => 'show', :id => @port
    else
      render :action => 'edit'
    end
  end

  def destroy
    Port.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @q = params[:q]
    @port_pages, @ports = paginate :ports, :per_page => 80, :order => 'name',
      :conditions => Port.build_query_conditions(@q)
  end
  
  def tag
    port = Port.find(params[:id])
    params[:tags].split(/,?[ ]+/).each do |t|
      if t =~ /\-(.*)/
        port.remove_tag($1) if $1
      elsif t =~ /\+?(.+)/
        port.add_tag($1)
      end
    end
    redirect_to :action => 'show', :id => port
  end
  
  def add_comment
    port = Port.find(params[:id])
    text = params[:text]
    
    if text
      # TODO: Figure out the real maintainer
      port.comments << Comment.create(:commenter => port.maintainers.first, :comment => text)
    end
    
    redirect_to :action => 'show', :id => port
  end

  private :add_comment
  private :create, :edit, :update, :destroy
  
end
