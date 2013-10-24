require '../SPOLKS_LIB/Sockets/XBasicSocket.rb'

class XTCPSocket < XBasicSocket
	attr_accessor :client_socket
	def initialize(port_number, host_name)
		@socket = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
		@sockaddr = Socket.sockaddr_in(port_number, host_name)
	end
	def listen
		@socket.bind(@sockaddr)
		@socket.listen(Constants::BACKLOG_VALUE)
		self.accept
	end
	def connect(sockaddr)
		@socket.connect(sockaddr)
	end
	def accept
		@client_socket, client_addrinfo = @socket.accept
		inspect_client(client_addrinfo)
	end
	def close
		@client_socket.close
		@socket.close
	end
end