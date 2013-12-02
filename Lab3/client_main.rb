require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'
require '../SPOLKS_LIB/Utility/UserOptionsParser.rb'
require_relative 'client.rb'

parser = UserOptionsParser.new
options = parser.parse

socket = XTCPSocket.new(options.get_port_number, options.get_host_name)
client = TCPClient.new(socket, options.get_filepath)
client.connect(options.get_server_port_number, options.get_host_name)