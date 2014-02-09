class SubmissionsController < ApplicationController
	cache_sweeper :installed_port_sweeper, :only => [:create, :update, :destroy]

	# GET /submissions
	# GET /submissions.xml
	def index
		@submissions = Submission.all

		respond_to do |format|
			format.html # index.html.erb
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
end
