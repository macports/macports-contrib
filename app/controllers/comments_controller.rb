class CommentsController < ApplicationController
  def edit
    @comment = Port.find(params[:port_id]).comments.find(params[:id])
  end

  def create
    @comment = Port.find(params[:port_id]).comments.build(params[:comment])

    respond_to do |format|
      if @comment.save
        format.html { redirect_to(@comment.port, :notice => 'Comment was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @comment = Port.find(params[:port_id]).comments.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to(@comment.port, :notice => 'Comment was successfully updated.') }
      else
        format.html { render :action => "edit" }
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
