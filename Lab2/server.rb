require '../SPOLKS_LIB/Sockets/XTCPSocket.rb'
require '../SPOLKS_LIB/Utility/FileTransfer.rb'

class Server
  def initialize(socket, filepath)
    @socket = socket
	@file_transfer = FileTransfer.new(filepath, Constants::READ_FILE_FLAG)
  end
  def start
	@socket.listen
	self.send_file
  end
  def send_file
    @file_transfer.divide_file_by_chunks { |chunk| @socket.client_socket.write(chunk) }
  end
  def stop
	@socket.close
  end
end