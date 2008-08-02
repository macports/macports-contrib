class FileBlobController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @file_blob_pages, @file_blobs = paginate :file_blobs, :per_page => 10
  end

  def show
    @file_blob = FileBlob.find(params[:id])
  end

  def new
    @file_blob = FileBlob.new
  end

  def create
    @file_blob = FileBlob.new(params[:file_blob])
    if @file_blob.save
      flash[:notice] = 'FileBlob was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @file_blob = FileBlob.find(params[:id])
  end

  def update
    @file_blob = FileBlob.find(params[:id])
    if @file_blob.update_attributes(params[:file_blob])
      flash[:notice] = 'FileBlob was successfully updated.'
      redirect_to :action => 'show', :id => @file_blob
    else
      render :action => 'edit'
    end
  end

  def destroy
    FileBlob.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  private :create, :edit, :update, :destroy
  
end
