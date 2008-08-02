class FileInfoController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @file_info_pages, @file_infos = paginate :file_infos, :per_page => 10
  end

  def show
    @file_info = FileInfo.find(params[:id])
  end

  def new
    @file_info = FileInfo.new
  end

  def create
    @file_info = FileInfo.new(params[:file_info])
    if @file_info.save
      flash[:notice] = 'FileInfo was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @file_info = FileInfo.find(params[:id])
  end

  def update
    @file_info = FileInfo.find(params[:id])
    if @file_info.update_attributes(params[:file_info])
      flash[:notice] = 'FileInfo was successfully updated.'
      redirect_to :action => 'show', :id => @file_info
    else
      render :action => 'edit'
    end
  end

  def destroy
    FileInfo.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
    
  private :create, :edit, :update, :destroy

end
