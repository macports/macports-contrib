class SubmissionsController < ApplicationController
  # GET /submissions
  # GET /submissions.xml
  def index
    @submissions = Submission.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /submissions/1
  # GET /submissions/1.xml
  def show
    @submission = Submission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # POST /submissions
  def create
    @submission = Submission.new(params[:submission])
    
    @submission.save_data
  
    respond_to do |format|
      format.html { redirect_to(@submission, :notice => 'Submission was successfully created.') }
    end
  end

  # GET /submits/new
  # GET /submits/new.xml
  def new
    @submit = Submission.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @submit }
    end
  end


  def destroy
    @submit = Submission.find(params[:id])
    @submit.destroy

    respond_to do |format|
      format.html { redirect_to(submissions_url) }
      format.xml  { head :ok }
    end
  end

end



