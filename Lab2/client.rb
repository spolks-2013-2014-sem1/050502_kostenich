require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'
require '../SPOLKS_LIB/Utility/FileTransfer.rb'

class Client
  def initialize(socket, filepath)
    @socket = socket
	@file_transfer = FileTransfer.new(filepath, Constants::WRITE_FILE_FLAG)
  end
  def connect(port_number, host_name)
    sockaddr = Socket.sockaddr_in(port_number, host_name)
	@socket.connect(sockaddr)
	self.receive_file {|chunk| @file_transfer.create_file_with_chunks(chunk)}
  end
  def receive_file
  	loop do
  	  rs, _ = IO.select([@socket.socket], nil, nil, Constants::TIMEOUT)
	  break unless rs

	  rs.each do |s|
        data = s.recv(Constants::CHUNK_SIZE)
	    return if data.empty?
	    if block_given?
	  	  yield data
	    end
	  end
	
  	end
  end
end