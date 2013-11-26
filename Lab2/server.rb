require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'
require '../SPOLKS_LIB/Utility/FileTransfer.rb'

class Server
  def initialize(socket, filepath)
    @socket = socket
	  @file = File.open(filepath, Constants::READ_FILE_FLAG)
  end
  def start
	  @socket.listen
	  self.send_file
  end
  def send_file
    while (chunk = @file.read(Constants::CHUNK_SIZE))
      @socket.client_socket.send(chunk, 0)
    end
  end
  def stop
	  @socket.close
    @file.close
  end
end