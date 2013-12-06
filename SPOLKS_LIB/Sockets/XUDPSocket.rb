require_relative "XBasicSocket.rb"

class XUDPSocket < XBasicSocket
  attr_accessor :socket, :client_sockaddr
  def initialize(port_number, host_name)
    @socket = Socket.new(Socket::AF_INET6, Socket::SOCK_DGRAM, 0)
    @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    @sockaddr = Socket.sockaddr_in(port_number, host_name)
  end
  def bind
    @socket.bind(@sockaddr)
  end
  def listen
    self.accept
  end
  def accept
    while(1)
      msg, @client_sockaddr = @socket.recvfrom(1)
      if (msg == Constants::UDP_MESSAGE)
        break
      end
    end
  end
  def send(msg, flags, dst_addr)
    @socket.send(msg, flags, dst_addr)
  end
  def connect(sockaddr)
    @socket.connect(sockaddr)
  end
  def close
    @socket.close
  end
end