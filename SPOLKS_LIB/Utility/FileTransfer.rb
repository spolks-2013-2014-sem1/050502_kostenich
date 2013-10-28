require '../SPOLKS_LIB/Utility/Constants.rb'

class FileTransfer
  def initialize(file_path, mode)
    @file = File.open(file_path, mode)
  end
  def divide_file_by_chunks
	while(chunk = @file.read(Constants::CHUNK_SIZE))
	  if block_given?
	    yield chunk
	  end
	end
  end
  def create_file_with_chunks(chunk)
    @file.write(chunk)
  end
  def close
    @file.close  
  end
end