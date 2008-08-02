require 'file_info'
require 'port_pkg'

class FileRef < ActiveRecord::Base
  belongs_to :file_info
  belongs_to :port_pkg
  
  def FileRef.create_from_path(path, path_root, options = {})
    ref = FileRef.new()
    
    # Create a new FileInfo object from specfied path
    new_info = FileInfo.new()
    new_info.read_from_path(path, path_root, options)
    
    # If we already had a FileInfo matching the specifics
    # (path and digests) then use that one, deleting the new
    existing_info = FileInfo.find_by_md5_and_sha256_and_file_path(
                      new_info.md5, new_info.sha256,
                      new_info.file_path,
                      :conditions => "id != #{new_info.id}")
    if (existing_info)
      ref.file_info = existing_info
      FileInfo.destroy(new_info)
    else
      ref.file_info = new_info
    end
    
    return ref
  end
  
  def <=>(other)
    if (self.file_info.file_path == other.file_info.file_path)
      return self.id <=> other.id
    else
      return self.file_info.file_path <=> other.file_info.file_path
    end
  end
  
end
