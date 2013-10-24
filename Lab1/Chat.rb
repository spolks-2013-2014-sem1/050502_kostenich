require '../SPOLKS_LIB/Utility/Constants.rb'
require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'

class Chat	
	def initialize(server_socket)
		@server = server_socket
	end

	def start_receiving_thread(client_socket)
		@receivingThread = Thread.new do
			while(true)
				message = client_socket.readline.chomp
				puts message
			end
		end
	end

	def start_sending_thread(client_socket)
		@sendingThread = Thread.new do
			while(true)
				message = gets
				if (message.chomp == Constants::STOP_MESSAGE)
					@should_continue = false
					client_socket.puts(Constants::SERVER_IS_OFFLINE)
					self.stop_receiving_thread
					break
				end
				client_socket.puts message
			end
		end
	end

	def stop_receiving_thread
		@receivingThread.exit
	end

	def stop_sending_thread
		@sendingThread.exit
	end

	def join_threads
		@sendingThread.join
		@receivingThread.join
	end

	def start
		@server.listen
		self.start_sending_thread(@server.client_socket)
		self.start_receiving_thread(@server.client_socket)
		self.join_threads
	end

	def stop
		@server.close
	end
end