require 'stringio'

require 'file_blob'
require 'file_ref'
require 'mpwa-conf'

class FileInfoException < RuntimeError
end

class FileInfo < ActiveRecord::Base
  has_many :file_refs
  #has_many :file_blobs -- we don't use this association to avoid keeping many blobs in memory
  before_destroy { |f| FileBlob.delete_all "file_info_id = #{f.id}" }
  
  def FileInfo.mimetype_from_path(path)
      mimetype = /^([^;]+)(;\w*(.*))?/.match(`#{MPWA::FILETOOL} --mime --brief #{path}`)[1]
  end

  def read_from_path(path, path_root = nil, options = {})
      mimetype = options[:mimetype] || FileInfo.mimetype_from_path(path)
      reported_path = options[:filename] || path_root.nil? ?
          path.to_s : Pathname.new(path).relative_path_from(path_root).to_s
          
      File.open(path, "r") { |f| read_from_file(f, :path => reported_path, :mimetype => mimetype) }
      return self
  end
  
  def read_from_file(file, options = {})
      # Save file meta information
      self.file_path = options[:path]
      self.length = 0
      self.mime_type = options[:mimetype] || 'application/octet-stream'
      
      # Save so that we get a primary id for the blob associations
      self.save
      
      # Create digesters for our digests
      md5 = Digest::MD5.new
      sha256 = Digest::SHA256.new
      
      # Read the file, creating blobs of data as we go
      buf = ''
      length = 0
      seq = 0
      while (file.read(MPWA::MAX_BLOB_SIZE, buf))
          # Update the digests
          md5.update buf
          sha256.update buf
          
          # Create a new bob
          blob = FileBlob.create(:file_info => self, :data => buf, :sequence => seq)

          length += buf.length
          seq += 1
      end
      
      # Finish up
      self.md5 = md5.hexdigest
      self.sha256 = sha256.hexdigest
      self.length = length
  
      self.save
      return self  
  end
  
  def write_to_file(file)
      # Create a digester so that we can verify the digest
      digest = Digest::MD5.new

      # Page in the blobs, writing to file as we go
      length = 0
      seq = 0
      while (length < self.length)
          blob = FileBlob.find(:first, :conditions => "file_info_id=#{self.id} and sequence=#{seq}")
          raise FileInfoException, "file_info missing segment" if !blob
          
          buf = blob.data
          digest.update buf
          
          file.write(buf)
          length += buf.length
          
          seq += 1
      end
      
      # Verify the digest
      raise FileInfoException, "digest mismatch while reading file_info #{self.id}" if digest.hexdigest != self.md5
  end
  
  def data()
      StringIO.open("rw") do |f|
          write_to_file(f)
          f.string
      end
  end
  
  
end
