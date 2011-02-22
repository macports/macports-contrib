# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#require 'recaptcha'
include Rack::Recaptcha::Helpers

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :current_user_session, :current_user

  $trac_url = 'http://trac.macports.org/'
  $svn_url = 'http://svn.macports.org/repository/macports/'
  $downloads_url = 'http://distfiles.macports.org/MacPorts/'
  $guide_url = 'http://guide.macports.org'
  $latest_version = '1.9.2'
  $snowleopard_dmg = "#{$downloads_url}Macports-#{$latest_version}-10.6-SnowLeopard.dmg"
  $leopard_dmg = "#{$downloads_url}Macports-#{$latest_version}-10.5-Leopard.dmg"
  $tiger_dmg = "#{$downloads_url}Macports-1.9.1-10.4-Tiger.dmg"
  $bz2_tarball = "#{$downloads_url}MacPorts-#{$latest_version}.tar.bz2"
  $gz_tarball = "#{$downloads_url}MacPorts-#{$latest_version}.tar.gz"
  $checksums = "#{$downloads_url}MacPorts-#{$latest_version}.chk.txt"

  $updated = Port.all(:order => 'updated_at DESC', :limit => 1).try(:first).try(:updated_at) || Time.at(0)

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      render :file => 'static/unauth.html', :status => :unauthorized
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      #redirect_to account_url
      return false
    end
  end

end
