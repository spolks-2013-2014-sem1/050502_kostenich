require '../SPOLKS_LIB/Sockets/XBasicSocket.rb'

class XTCPSocket < XBasicSocket
  attr_accessor :client_socket, :socket
  def initialize(port_number, host_name)
    @socket = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
    @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    @sockaddr = Socket.sockaddr_in(port_number, host_name)
  end
  def bind
    @socket.bind(@sockaddr)
    @socket.listen(Constants::BACKLOG_VALUE)
  end
  def listen
    self.accept
  end
  def listen_nonblock
    begin
      @client_socket, client_addrinfo = @socket.accept_nonblock  
    rescue 
    end
  end
  def connect(sockaddr)
    @socket.connect(sockaddr)
  end
  def accept
    @client_socket, client_addrinfo = @socket.accept
    inspect_client(client_addrinfo)
  end
  def close
    @socket.close
  end
end