require '../SPOLKS_LIB/Utility/Constants.rb'

class UserOptions
	def initialize
		@options = {}
		@options[:host_name] = Constants::DEFAULT_HOST_NAME
		@options[:port_number] = Constants::DEFAULT_PORT_NUMBER
	end
	def set_udp_socket
		@options[:udp] = true
	end
	def set_host_name(name)
		if(name != nil) 
			@options[:host_name] = name
		end
	end
	def set_port_number(port)
		if(port != nil)
			@options[:port_number] = port
		end
	end
	def set_server_port_number(port)
		@options[:server_port] = port
	end
	def set_filepath(path)
		@options[:filepath] = path
	end
	def get_udp_socket
		return @options[:udp]
	end
	def get_host_name
		return @options[:host_name]
	end
	def get_port_number
		return @options[:port_number]
	end	
	def get_server_port_number
		return @options[:server_port]
	end
	def get_filepath
		return @options[:filepath]
	end
end