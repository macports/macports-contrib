class CommentsController < ApplicationController
  cache_sweeper :comment_sweeper, :only => [:create]

  def create
    @comment = Port.find(params[:port_id]).comments.build(params[:comment])

    respond_to do |format|
      if recaptcha_valid?
        if @comment.save
          format.html { redirect_to category_port_path(@comment.port.category, @comment.port) }
        end
      else
        flash[:error] = "There was an error with the recaptcha code below. Please re-enter the code and click submit." 
        format.html { redirect_to category_port_path(@comment.port.category, @comment.port) }
      end
    end
  end

  def destroy
    @comment = Port.find(params[:port_id]).comments.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(port_comments_url(@comment.port)) }
    end
  end
end
