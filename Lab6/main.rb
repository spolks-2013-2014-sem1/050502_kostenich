require 'socket'
require 'bindata'
require '../SPOLKS_LIB/Utility/UserOptionsParser.rb'
require '../SPOLKS_LIB/Sockets/network.rb'
require_relative 'transmitter'

parser = UserOptionsParser.new
options = parser.parse

begin

  if(options.get_udp_socket)
    Transmitter::start_udp_server(options.get_port_number, options.get_host_name, options.get_filepath)
  else
    Transmitter::start_tcp_server(options.get_port_number, options.get_host_name, options.get_filepath)
  end

rescue Interrupt => e
  puts " Exit"
rescue Errno::EPIPE => e
  puts "!! Client was disconnected"
rescue Errno::ECONNREFUSED => e
  puts "socket is disabled"
  puts "#{e}"
rescue Errno::ENOENT => e
  puts "No such file or directory"
end