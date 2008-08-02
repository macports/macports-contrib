class TagController < ApplicationController
    
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @tag_pages, @tags = paginate :tags, :per_page => 128, :order => 'name'
  end

  def show
    if !params[:name].nil?
        @key = params[:name]
        @tag = Tag.find_by_name(params[:name])
        render :action => 'notag' if @tag.nil?
    else
        @key = params[:id]
        @tag = Tag.find(params[:id])
        render :action => 'notag' if @tag.nil?
    end
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = 'Tag was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = 'Tag was successfully updated.'
      redirect_to :action => 'show', :id => @tag
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tag.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  private :create, :edit, :update, :destroy
  
end
