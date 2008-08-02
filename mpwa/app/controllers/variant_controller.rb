class VariantController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @variant_pages, @variants = paginate :variants, :per_page => 10
  end

  def show
    @variant = Variant.find(params[:id])
  end

  def new
    @variant = Variant.new
  end

  def create
    @variant = Variant.new(params[:variant])
    if @variant.save
      flash[:notice] = 'Variant was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @variant = Variant.find(params[:id])
  end

  def update
    @variant = Variant.find(params[:id])
    if @variant.update_attributes(params[:variant])
      flash[:notice] = 'Variant was successfully updated.'
      redirect_to :action => 'show', :id => @variant
    else
      render :action => 'edit'
    end
  end

  def destroy
    Variant.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  private :create, :edit, :update, :destroy
  
end
