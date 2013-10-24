require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'
require '../SPOLKS_LIB/Utility/UserOptionsParser.rb'
require 'Chat.rb'

parser = UserOptionsParser.new
options = parser.parse
p options
socket = XTCPSocket.new(options.get_port_number, options.get_host_name)
chat = Chat.new(socket)
chat.start
chat.stop