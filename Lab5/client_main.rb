require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'
require '../SPOLKS_LIB/Sockets/XUDPSocket.rb'
require '../SPOLKS_LIB/Utility/UserOptionsParser.rb'
require '../Lab3/client.rb'
require_relative 'client.rb'

parser = UserOptionsParser.new
options = parser.parse

if(options.get_udp_socket)
  socket = XUDPSocket.new(options.get_port_number, options.get_host_name)
  client = UDPClient.new(socket, options.get_filepath)
else
  socket = XTCPSocket.new(options.get_port_number, options.get_host_name)
  client = TCPClient.new(socket, options.get_filepath)
end


client.connect(options.get_server_port_number, options.get_host_name)