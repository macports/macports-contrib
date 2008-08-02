class PersonController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @person_pages, @people = paginate :people, :per_page => 30, :order => 'last_name, first_name, user_name'
  end

  def show
    @person = Person.find(params[:id])
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      flash[:notice] = 'Person was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(params[:person])
      flash[:notice] = 'Person was successfully updated.'
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'edit'
    end
  end

  def destroy
    Person.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def validation_request
    @person = Person.find(params[:id])
    
    # Check captcha result
    if (params[:a].to_i + params[:b].to_i == params[:sum].to_i)
      # Create token
      token = Token.create(:type => 'validation', :random => rand(999999999), :expires => DateTime.now() + 1)
      Notifier.deliver_user_validation(@person, token)
      flash[:notice] = 'Validation email sent'     
    elsif
      flash[:notice] = 'Incorrect sum'
    end
    redirect_to :action => 'show', :id => @person
  end
  
  private :create, :edit, :update, :destroy
end
