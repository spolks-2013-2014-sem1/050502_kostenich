require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'
require '../SPOLKS_LIB/Sockets/XUDPSocket.rb'
require '../SPOLKS_LIB/Utility/UserOptionsParser.rb'
require_relative 'server.rb'

parser = UserOptionsParser.new
options = parser.parse

if(options.get_udp_socket)
  socket = XUDPSocket.new(options.get_port_number, options.get_host_name)
  server = UDPServer.new(socket, options.get_filepath)
else
  socket = XTCPSocket.new(options.get_port_number, options.get_host_name)
  server = TCPServer.new(socket, options.get_filepath) 
end

server.start
server.stop