require 'port_pkg'

class PortPkgController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @port_pkg_pages, @port_pkgs = paginate :port_pkgs, :per_page => 10
  end

  def show
    @port_pkg = PortPkg.find(params[:id])
  end

  def new
    @port_pkg = PortPkg.new
  end

  def create
    @port_pkg = PortPkg.new(params[:port_pkg])
    if @port_pkg.save
      flash[:notice] = 'PortPkg was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @port_pkg = PortPkg.find(params[:id])
  end

  def update
    @port_pkg = PortPkg.find(params[:id])
    if @port_pkg.update_attributes(params[:port_pkg])
      flash[:notice] = 'PortPkg was successfully updated.'
      redirect_to :action => 'show', :id => @port_pkg
    else
      render :action => 'edit'
    end
  end

  def destroy
    PortPkg.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def submit
    portpkg = params[:portpkg]

    begin
        # Validate parameters (we're probably making this too hard)
        raise "bad package" if portpkg.nil?

        # Create a package from the file
        @port_pkg = PortPkg.create_from_file(portpkg)
        
        download_url = portpkg_url(:id => @port_pkg)
        human_url = url_for(:controller => "port_pkg", :action => "show", :id => @port_pkg)
        render :text => "STATUS: 0\n" +
            "MESSAGE: PortPkg submitted successfully\n" +
            "DOWNLOAD_URL: #{download_url}\n" +
            "HUMAN_URL: #{human_url}\n"
    rescue FileInfoException => ex
        render :text => "STATUS: 1\n" +
            "MESSAGE: Error during submit: #{ex}\n", :status => 400
    end
  end
  
  def emit_portpkg
    port_pkg = PortPkg.find(params[:id])
    redirect_to :controller => 'file_ref', :action => 'emit',
        :id => port_pkg.portpkg_file_ref()
  end
  
  def emit_portpkg_path
    port_pkg = PortPkg.find(params[:id])
    redirect_to :controller => 'file_ref', :action => 'emit',
        :id => port_pkg.file_ref_by_path(params[:path].join, '/')
  end
  
  def tag
    port_pkg = PortPkg.find(params[:id])
    params[:tags].split(/,?[ ]+/).each do |t|
      if t =~ /\-(.*)/
        port_pkg.remove_tag($1) if $1
      elsif t =~ /\+?(.+)/
        port_pkg.add_tag($1)
      end
    end
    redirect_to :action => 'show', :id => port_pkg
  end
  
  def add_comment
    port_pkg = PortPkg.find(params[:id])
    text = params[:text]
    
    if text
      # TODO: Figure out the real maintainer
      port_pkg.comments << Comment.create(:commenter => port_pkg.submitter, :comment => text)
    end
    
    redirect_to :action => 'show', :id => port_pkg
  end
  
  private :add_comment
  private :create, :edit, :update, :destroy
  
end
