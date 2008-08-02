require 'file_info'

class FileBlob < ActiveRecord::Base
    belongs_to :file_info
    
    def read(file)
        self.data = file.read
    end
end
