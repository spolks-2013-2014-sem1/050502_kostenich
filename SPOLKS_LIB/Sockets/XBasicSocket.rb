require 'socket'
require '../SPOLKS_LIB/Utility/Constants.rb'

class XBasicSocket
	def listen
		raise NotImplementedError, Constants::IMPLEMENT_THIS_METHOD
	end

	def connect
		raise NotImplementedError, Constants::IMPLEMENT_THIS_METHOD
	end

	def close
		raise NotImplementedError, Constants::IMPLEMENT_THIS_METHOD
	end

	def accept
		raise NotImplementedError, Constants::IMPLEMENT_THIS_METHOD
	end

	def inspect_client (addrinfo)
		puts(Constants::CONNECTED_CLIENT_WAS)
		Socket.getnameinfo(addrinfo).each { |line| puts(line) }
	end
end