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

class TCPClient
  def initialize(socket, filepath)
    @socket = socket
    @file = File.open(filepath, Constants::WRITE_FILE_FLAG)
    @received_data = 0
  end
  def connect(port_number, host_name)
    sockaddr = Socket.sockaddr_in(port_number, host_name)
    @socket.connect(sockaddr)
    self.receive_file {|chunk| @file.write(chunk)}
    @file.close
  end
  def receive_file
    loop do
      rs, _, us = IO.select([@socket.socket], nil, [@socket.socket], Constants::TIMEOUT)

      us.each do |s|
        begin
          puts s.recv(1, Socket::MSG_OOB)  
          puts @received_data
        rescue Exception => e
          next
        end
      end

      rs.each do |s|
        data = s.recv(Constants::CHUNK_SIZE)
        return if data.empty?
        @received_data += data.length
        if block_given?
          yield data
        end
      end
    end
  end
end