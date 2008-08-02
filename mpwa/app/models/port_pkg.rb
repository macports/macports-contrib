require 'time'
require 'temp_directories'
require 'rexml/document'

require 'mpwa-conf'
require 'file_ref'
require 'file_info'
require 'person'
require 'port'
require 'variant'
require 'tag'

PortPkgMeta = Struct.new("PortPkgMeta",
    :submitter_email, :submitter_name, :submitter_notes,
    :name, :epoch, :version, :revision,
    :short_desc, :long_desc, :home_page,
    :maintainers, :variants, :categories)
    
VariantMeta = Struct.new("VariantMeta",
    :name, :description)

class PortPkgException < RuntimeError
end

class PortPkg < ActiveRecord::Base
    belongs_to :port
    belongs_to :submitter, :class_name => 'Person', :foreign_key => 'submitter_id'
    has_many :file_refs, :dependent => :destroy
    has_many :file_infos, :through => :file_refs
    has_many :variants, :dependent => :destroy
    has_and_belongs_to_many :tags
    has_and_belongs_to_many :comments
    
    def PortPkg.create_from_file(file)
        portpkg = PortPkg.new
        portpkg.import_from_file(file)
    end
    
    def PortPkg.extract_pkg_meta_from_file(f)
        # This function parses the xml metadata file from a portpkg,
        # and creates a canonical internal form for our exclusive use
        
        meta = PortPkgMeta.new()
        doc = REXML::Document.new(f)
        
        root_el = doc.root
        submitter_el = root_el.elements["submitter"]
        package_el = root_el.elements["package"]
        
        meta[:submitter_email] = submitter_el.elements["email"].text
        meta[:submitter_name] = submitter_el.elements["name"].text
        meta[:submitter_notes] = submitter_el.elements["notes"].text
        
        meta[:name] = package_el.elements["name"].text
        meta[:epoch] = package_el.elements["epoch"].text
        meta[:version] = package_el.elements["version"].text
        meta[:revision] = package_el.elements["revision"].text
        
        meta[:short_desc] = package_el.elements["description"].text;
        meta[:long_desc] = package_el.elements["long_description"].text;
        meta[:home_page] = package_el.elements["homepage"].text;
            
        meta[:maintainers] = []
        package_el.elements.each("maintainers/maintainer") { |m| meta.maintainers << m.text }
        
        meta[:variants] = []
        package_el.elements.each("variants/variant")  do |v|
          variant = VariantMeta.new()
          variant[:name] = v.elements["name"].text
          variant[:description] = v.elements["description"].text if v.elements["description"]
          meta.variants << variant
        end
        
        meta[:categories] = []
        package_el.elements.each("categories/category")  { |c| meta.categories << c.text }

        return meta
    end
    
    def import_from_file(file)
        raise PortPkgException, "nil file_path" if file.nil?
        
        # Make a temporary directory
        tempDirPath = TempDirectories.makeTempDir
        
        # Write the portpkg file to the temporary directory
        pkgPath = tempDirPath + "portpkg.portpkg"
        metaName = "portpkg_meta.xml"
        metaPath = tempDirPath + metaName
 
        expandedPkgPath = tempDirPath + "portpkg"
        File.open(pkgPath, "w") { |f| f.write(file.read) }
        
        # Note: a bug in xar presently prevents us from limiting the extraction to the portpkg directory,
        # => which we'd like to do for the sake of cleanliness. Hopefully this will become fixed soon.
        raise PortPkgException, "xar tool not executable" if !File.executable?(MPWA::XARTOOL)
        system("cd #{tempDirPath}; #{MPWA::XARTOOL} -xf #{pkgPath} -s #{metaPath} -n #{metaName}")
        raise PortPkgException, "error extracting portpkg from xar archive" if $? != 0
        raise PortPkgException, "no meta information file" if !metaPath.file?
         
        # Parse the meta information       
        meta = nil
        File.open(metaPath, "r") { |f| meta = PortPkg.extract_pkg_meta_from_file(f) }
        
        # Fill-in portpkg information from metadata
        raise PortPkgException, "no submitter email" if meta.submitter_email.nil? || meta.submitter_email.empty?
        self.submitted_at = Time.now
        self.submitter = Person.ensure_person_with_email(meta.submitter_email, meta.submitter_name)
        self.submitter_notes = meta.submitter_notes
        
        self.name = meta.name
        self.short_desc = meta.short_desc
        self.long_desc = meta.long_desc
        self.home_page = meta.home_page
        
        self.epoch = meta.epoch
        self.version = meta.version
        self.revision = meta.revision
        
        # Map to, and/or create, a port
        self.port = Port.ensure_port(meta.name, meta)
        
        # Save before we add variants and tags
        self.save        
        
        # Add the variants
        meta.variants.each do |v|
          self.variants << Variant.new(:name => v.name, :description => v.description)
        end
        
        # Tag with categories
        meta.categories.each { |c| self.add_tag(c) }
        
        # Save unpacked data into a file
        portpkg_ref = FileRef.create_from_path(pkgPath, tempDirPath,
                            :mimetype => 'application/vnd.macports.portpkg')
        portpkg_ref.is_port_pkg = true
        self.file_refs << portpkg_ref
        
        # Save files from the expanded package
        expandedPkgPath.find do |p|
            self.file_refs << FileRef.create_from_path(p, tempDirPath) if p.file?
        end
        
        # Final save
        self.save
        
        # Cleanup the temp directory
        tempDirPath.rmtree
        
        # Return the port_pkg
        return self
     end
    
    def file_ref_by_path(file_path)
        candidates = self.file_refs.select { |r| r.file_info.file_path == file_path }
        return candidates ? candidates.first : nil
    end
    
    def portpkg_file_ref()
        candidates = self.file_refs.select { |r| r.is_port_pkg }
        return candidates ? candidates.first : nil
    end
    
    def data_file_refs()
        refs = self.file_refs.select { |r| !r.is_port_pkg }
        return refs
    end
    
    def add_tag(name)
        tag = Tag.find_or_create_by_name(name)
        self.tags << tag unless self.tags.include?(tag)
    end
    
    def remove_tag(name)
        self.tags.select { |t| t.name == name }.each { |t| self.tags.delete(t) }
    end
    
    def <=>(other)
        self.id <=> other.id
    end

end
