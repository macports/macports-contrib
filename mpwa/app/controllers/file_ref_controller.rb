class FileRefController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @file_ref_pages, @file_refs = paginate :file_refs, :per_page => 10
  end

  def show
    @file_ref = FileRef.find(params[:id])
  end

  def new
    @file_ref = FileRef.new
  end

  def create
    @file_ref = FileRef.new(params[:file_ref])
    if @file_ref.save
      flash[:notice] = 'FileRef was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @file_ref = FileRef.find(params[:id])
  end

  def update
    @file_ref = FileRef.find(params[:id])
    if @file_ref.update_attributes(params[:file_ref])
      flash[:notice] = 'FileRef was successfully updated.'
      redirect_to :action => 'show', :id => @file_ref
    else
      render :action => 'edit'
    end
  end

  def destroy
    FileRef.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def emit
    ref = FileRef.find(params[:id])
    send_data ref.file_info.data,
      :filename => ref.file_info.file_path,
      :type => ref.file_info.mime_type,
      :disposition => 'inline'

    # Bump download counts for the ref, and for the portpkg too if the file is a portpkg.
    FileRef.increment_counter('download_count', ref)
    PortPkg.increment_counter('download_count', ref.port_pkg) if ref.is_port_pkg
  end
  
  private :create, :edit, :update, :destroy
  
end
