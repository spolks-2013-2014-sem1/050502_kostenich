require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'

class UDPServer
  def initialize(socket, filepath)
    @socket = socket
    @file = File.open(filepath, Constants::READ_FILE_FLAG)
  end
  def start
    @socket.bind
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

class TCPServer
  def initialize(socket, filepath)
    @socket = socket
    @filepath = filepath
    @file = File.open(filepath, Constants::READ_FILE_FLAG)
    @oob_data = 0
    @send_data = 0
    @connections = {}
    @last_client = nil
  end 
  def start
    @socket.bind
    self.send_file
  end
  def send_file
    loop do
      if(@first_time)
        @socket.listen
      else
        @socket.listen_nonblock
      end
      if @socket.client_socket
        if(@connections[@socket.client_socket] == nil && @last_client != @socket.client_socket)
          @last_client = @socket.client_socket
           @connections[@socket.client_socket] = {
            file: File.open(@filepath, Constants::READ_FILE_FLAG),
            sent: 0
          }
        end
        
        return if @connections.length == 0 
        _, ws, = IO.select(nil, @connections.keys, nil, Constants::TIMEOUT)
        break unless ws

        ws.each do |s|
          chunk = @connections[s][:file].read(Constants::CHUNK_SIZE)
          if not chunk
            @connections[s][:file].close
            @connections.delete(s)
            next
          end
          s.send(chunk, 0)
          self.get_data_info(chunk, s)
          sleep(Constants::DELAY_BETWEEN_CHUNKS)
        end
      end
    end
  end
  def get_data_info(chunk, client)
    @oob_data += 1
    STDOUT.puts @connections[client][:sent]
    self.send_oob_data(client)
    @connections[client][:sent] += chunk.length
  end
  def send_oob_data(client)
    if @oob_data % 32 == 0
      @oob_data = 0
      STDOUT.puts "SEND OOB MESSAGE"
      client.send(Constants::OOB_MESSAGE, Socket::MSG_OOB)
    end
  end
  def stop
    @socket.close
    @file.close
  end
end