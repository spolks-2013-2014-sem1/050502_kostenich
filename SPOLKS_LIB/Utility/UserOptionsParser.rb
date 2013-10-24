require "optparse"
require '../SPOLKS_LIB/Utility/UserOptions.rb'

class UserOptionsParser
	def initialize
		@options = UserOptions.new
	end
	def parse
		@opt_parser = OptionParser.new do |opt|
			opt.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS]"
			opt.separator ""
			opt.separator "SPECIFIC OPTIONS:"

			opt.on("-n HOSTNAME", "Hostname for creating socket. By default: localhost") do |n|
				@options.set_host_name(n)
			end

			opt.on("-p PORTNUMBER", "Port number for creating socket. By default: 2200") do |p|
				@options.set_port_number(p)
			end

			opt.on("-s SERVERPORT", "Server's port number to connect. By default: nil") do |s|
				@options.set_server_port_number(s)
			end

			opt.on("-f FILEPATH", "Path to file you want to send. By default: nil") do |f|
				@options.set_filepath(f)
			end

			opt.separator ""
			opt.separator "COMMON OPTIONS:"

			opt.on_tail("-h", "Show help message") do
				puts opt
				exit
			end

			opt.on_tail("-v", "Show version") do
				puts "Option parser by eXiga, version 1.0"
				exit
			end
		end.parse!
		return @options
	end
end