require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'

class UDPServer
  def initialize(socket, filepath)
    @socket = socket
    @file = File.open(filepath, Constants::READ_FILE_FLAG)
  end
  def start
	  @socket.listen
	  self.send_file
  end
  def send_file
    while (chunk = @file.read(Constants::CHUNK_SIZE / Constants::CHUNK_SIZE_DIVIDER_FOR_UDP))
      @socket.send(chunk, 0, @socket.client_sockaddr)
    end
    @socket.send(Constants::UDP_MESSAGE, 0, @socket.client_sockaddr)
  end
  def stop
	  @socket.close
    @file.close
  end
end