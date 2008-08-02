require "fileutils"

# NOTE: THIS CODE IS OBSOLETE AND NOT BEING USED AT PRESENT
#
# But it is an example to use in case we decide to auto-commit
# some things into svn

class PortsController < ApplicationController
  
    def makeTempDir()
        tmpdir = Dir::tmpdir
        basename = "mpwa"
        n = 1
        begin
            tmpname = File.join(tmpdir, sprintf('%s.%d.%d', basename, $$, n))
            n += 1
            next if File.exist?(tmpname)
            begin
                Dir.mkdir(tmpname)
            rescue SystemCallError
                next
            end
        end while !File.exist?(tmpname)
        return tmpname
    end

    def subversionCommand(args)
        puts "subversion: #{svn} #{args}"
        `#{svn} #{args}`
    end

    def ensureRepositoryPath(root, path)
        # Make sure the root director exists
        assert { File.directory?(root) }
        
        # Step through path, building each component that doesn't exist
        Pathname.new(path).descend do |p|
            full = Pathname.new(root) + p
            if !full.directory?
                full.mkdir
                subversionCommand("add #{full}")
                subversionCommand("commit -m 'Make repository path segment' #{full}")
             end
        end
    end
    
    def buildPortPkgDirPrefixPath(pkgId)
    	# Two Level Cache
    	# First level is low 6 bits of pkgId
    	# Second level is next 6 bits of pkgId
 
    	lev1 = pkgId & 0x3f
    	lev2 = pkgId >> 6 & 0x3f
    	path = format('%02x/%02x', lev1, lev2)
    end

    def buildPortPkgDirPath(pkgId)
        prefix = buildPortPkgDirPrefixPath(pkgId)
    	path = format('%s/%016x', prefix, pkgId)
    end

    def submit
        # TODO:
        # => Move some of this into the model
        # => And/or break up into more methods
        
        # Get and validate parameters
        @portName = params[:portname]
        @portpkg = params[:portpkg]
        
        # Validate parameters (we're probably making this too hard)
        raise "bad portName" if @portName.nil?
        raise "bad package" if @portpkg.nil?
        
        tempDir = makeTempDir
        portpkg = "#{tempDir}/portpkg.xar"
        pkgdir = "#{tempDir}/portpkg"
        common = "#{tempDir}/common"
        target = "#{tempDir}/target"

        # Form partial path to the common directory for the portname
        firstChar = @portName[0,1].downcase
        commonPartial = "common/#{firstChar}/#{@portName}"
        
        # Look for, and create if not found, the common directory for the port
        ensureRepositoryPath(repo_portpkgs, commonPartial)
        
        # Unpack the submitted portdir into a temporary directory
        File.open(portpkg, "w") { |f| f.write(@portpkg.read) }
        
        # Note: a bug in xar presently prevents us from limiting the extraction to the portpkg directory,
        # => which we'd like to do for the sake of cleanliness. Hopefully this will become fixed soon.
        system("cd #{tempDir}; #{xar} -xf #{portpkg}")
        
        # Check out a private temporary copy of the common directory
        # so that we don't get into concurrency issues by multi-modifying the directory
        subversionCommand("co #{repo_portpkgs_url}/#{commonPartial} #{common}")
        
        # Sync the submission into the common directory by parsing the results of mtree
        changeCnt = 0
        treeOut = `#{mtree} -c -k type,cksum -p #{pkgdir} | #{mtree} -p #{common}`
        treeOut.each_line do |line|
            puts "Line #{line}"
            
            case line
            when /^\w+/
                puts "Whitespace line #$1"
                
            when /^(.*) changed$/
                srcFile = File.join(pkgdir, $1)
                dstFile = File.join(common, $1)
                puts "Changed file #{srcFile} != #{dstFile}"
                FileUtils.cp(srcFile, dstFile)
                changeCnt += 1
                
            when /^(.*) extra$/
                dstFile = File.join(common, $1)
                if /^\./ =~ File.basename(dstFile)
                    puts "Skipping invisible extra entry #{dstFile}"
                else
                    puts "Extra entry #{dstFile}"
                    subversionCommand("rm #{dstFile}")
                    changeCnt += 1
               end
                
            when /^(.*) missing$/
                srcFile = File.join(pkgdir, $1)
                dstFile = File.join(common, $1)

                if /^\./ =~ File.basename(dstFile)
                    puts "Skipping invisible new entry #{dstFile}"
                else
                    puts "New entry #{srcFile} ==> #{dstFile}"
 
                    if File.directory?(srcFile)
                        subversionCommand("mkdir #{dstFile}")
                    else
                        FileUtils.cp(srcFile, dstFile)
                        subversionCommand("add #{dstFile}")
                    end
                    
                    changeCnt += 1
                end

            end
        end
        
        if changeCnt == 0
            puts "No changes detected, so don't create a new submission"
        else
            puts "Creating new submission from #{common}"

            # Commit changes to the common directory
            commitOutput = subversionCommand("commit -m 'New portpkg of #{@portName}' #{common}")
            commitRevision = /^Committed revision (\d+)./.match(commitOutput)[1]
            
            # Form the portid from the committed revision number
            pkgId = commitRevision.to_i
            portPkgDirPrefix = buildPortPkgDirPrefixPath(pkgId)
            portPkgDir = buildPortPkgDirPath(pkgId);
            
            puts "Creating new portpkg #{pkgId} at #{repo_portpkgs}/#{portPkgDir}"
    
            # Make sure there's a path to the repository location for the portPkg
            ensureRepositoryPath(repo_portpkgs, portPkgDirPrefix)
            
            # Make the portPkg directory
            FileUtils.mkdir("#{repo_portpkgs}/#{portPkgDir}")
            subversionCommand("add #{repo_portpkgs}/#{portPkgDir}")
     
            # Add original package and meta directory
            FileUtils.cp(portpkg, "#{repo_portpkgs}/#{portPkgDir}/portpkg.xar")
            FileUtils.mkdir("#{repo_portpkgs}/#{portPkgDir}/meta")
            subversionCommand("add #{repo_portpkgs}/#{portPkgDir}/portpkg.xar #{repo_portpkgs}/#{portPkgDir}/meta")
    
            # Copy the common directory into unpacked
            subversionCommand("cp #{common} #{repo_portpkgs}/#{portPkgDir}/unpacked")
    
            # Commit the portpkg directory
            subversionCommand("commit -m 'Complete portpkg #{pkgId} of port #{@portName}' #{repo_portpkgs}/#{portPkgDir}")
        end
    end
  
end
