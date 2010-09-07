# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#require 'recaptcha'
include Rack::Recaptcha::Helpers

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  $trac_url = 'http://trac.macports.org/'
  $svn_url = 'http://svn.macports.org/repository/macports/'
  $downloads_url = 'http://distfiles.macports.org/MacPorts/'
  $guide_url = 'http://guide.macports.org'
  $latest_version = '1.9.1'
  $snowleopard_dmg = "#{$downloads_url}Macports-#{$latest_version}-10.6-SnowLeopard.dmg"
  $leopard_dmg = "#{$downloads_url}Macports-#{$latest_version}-10.5-Leopard.dmg"
  $tiger_dmg = "#{$downloads_url}Macports-#{$latest_version}-10.4-Tiger.dmg"
  $bz2_tarball = "#{$downloads_url}MacPorts-#{$latest_version}.tar.bz2"
  $gz_tarball = "#{$downloads_url}MacPorts-#{$latest_version}.tar.gz"
  $checksums = "#{$downloads_url}MacPorts-#{$latest_version}.chk.txt"

  $updated = Port.all(:order => 'updated_at DESC', :limit => 1).try(:first).try(:updated_at) || Time.at(0)
end
