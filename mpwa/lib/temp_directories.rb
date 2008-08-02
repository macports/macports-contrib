require "fileutils"

class TempDirectories
    
    def TempDirectories.makeTempDir
        # Note: for long running processes, we should really incorporate time or randomness into this
        tmpdir = Dir::tmpdir
        basename = "mpwa"
        n = 1
        begin
            tmpname = Pathname.new(tmpdir) + sprintf('%s.%d.%d', basename, $$, n)
            n += 1
            next if tmpname.exist?
            begin
                tmpname.mkdir
            rescue SystemCallError
                next
            end
        end while !tmpname.exist?
        return tmpname
    end

end

