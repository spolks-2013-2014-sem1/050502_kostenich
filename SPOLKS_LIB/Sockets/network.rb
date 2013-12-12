require 'socket'
require 'bindata'
include Socket::Constants

module Network
  include Socket::Constants
  
  PACK_SIZE = 1024
  TIMEOUT  = 10
  BACK_LOG = 5
  ACK = 'ACK'
  FIN = 'FIN'

  class ServerTCP < Socket
    def initialize(port, host)
      super(AF_INET6, SOCK_STREAM, 0)
      setsockopt(SOL_SOCKET, SO_REUSEADDR, true)
      sockaddr = Socket.sockaddr_in(port, host)
      bind(sockaddr)
      listen(BACK_LOG)
    end
  end

  class ClientTCP < Socket
    def initialize(port, host)
      super(AF_INET6, SOCK_STREAM, 0)
      setsockopt(SOL_SOCKET, SO_REUSEADDR, true)
      sockaddr = Socket.sockaddr_in(port, host)
      connect(sockaddr)
    end
  end

  class ServerUDP < Socket
    def initialize(port, host)
      super(AF_INET6, SOCK_DGRAM, 0)
      setsockopt(SOL_SOCKET, SO_REUSEADDR, true)
      bind(Socket.sockaddr_in(port, host))
    end
  end

  class ClientUDP < Socket
    def initialize(port, host)
      super(AF_INET6, SOCK_DGRAM, 0)
      setsockopt(SOL_SOCKET, SO_REUSEADDR, true)
    end
  end

  class Packet < BinData::Record
    endian :little
    uint32 :chunks
    uint32 :len
    uint32 :seek
    string :data, :read_length => :len
  end

end