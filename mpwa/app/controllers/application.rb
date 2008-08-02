# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

    attr_reader :svn, :tar, :xar, :mtree
	attr_reader :repo_url, :repo_root, :repo_portpkgs, :repo_portpkgs_url
    attr_reader :main_tags

    helper :table

	def initialize
		@svn = "/opt/local/bin/svn"
		@xar = "/opt/local/bin/xar"
		@tar = "/usr/bin/tar"
		@mtree = "/usr/sbin/mtree"
		
		@repo_url = "file:///Users/jberry/Projects/macports/users/jberry/mpwa/testrepo/repo"
		@repo_root = "/Users/jberry/Projects/macports/users/jberry/mpwa/testrepo/root"
		@repo_portpkgs = "#{@repo_root}/portpkgs"
		@repo_portpkgs_url = "#{@repo_url}/portpkgs"
		
		@main_tags = [
		    'aqua', 'archivers', 'audio', 'benchmarks', 'cad', 'comms', 'cross',
            'databases', 'devel', 'editors', 'emulators', 'fuse', 'games',
            'genealogy', 'gnome', 'gnustep', 'graphics', 'irc', 'java', 'kde',
            'lang', 'mail', 'math', 'multimedia', 'net', 'news', 'palm', 'perl',
            'print', 'python', 'ruby', 'science', 'security', 'shells', 'sysutils',
            'tex', 'textproc', 'www', 'x11', 'zope'
            ]
	end
	
end