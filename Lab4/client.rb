require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'

class UDPClient
  def initialize(socket, filepath)
    @socket = socket
    @file = File.open(filepath, Constants::WRITE_FILE_FLAG)
  end
  def connect(port_number, host_name)
    sockaddr = Socket.sockaddr_in(port_number, host_name)
    @socket.send(Constants::UDP_MESSAGE, 0, sockaddr)
	  @socket.connect(sockaddr)
	  self.receive_file {|chunk| @file.write(chunk)}
    @file.close
  end
  def receive_file
  	loop do
  	  rs, _, us = IO.select([@socket.socket], nil, [@socket.socket], Constants::TIMEOUT)
      break unless rs

      rs.each do |s|
        data = s.recv(Constants::CHUNK_SIZE / Constants::CHUNK_SIZE_DIVIDER_FOR_UDP)
	      return if (data.empty? || data == Constants::UDP_MESSAGE)
	      if block_given?
	  	    yield data
	      end
	    end
  	end
  end
end