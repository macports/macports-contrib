class PagesController < ApplicationController
  def show
    respond_to do |format|
      format.html { render :action => params[:page] }
    end
  end
end
