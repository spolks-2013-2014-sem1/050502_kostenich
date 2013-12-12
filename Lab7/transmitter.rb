require 'socket'
require 'securerandom'
require 'process_shared'
require 'fileutils'
require '../SPOLKS_LIB/Sockets/network.rb'

module Transmitter
  MSG = '*'
  module_function

  def start_tcp_server(port, host, file_name)
    processes = []

    current_path = Dir.pwd
    FileUtils.mkdir_p(current_path + '/received')
    dir = Dir.new("received")

    server = Network::ServerTCP.new(port, host)

    Signal.trap 'CLD' do
      pid = Process.wait(-1)
      processes.delete(pid)
    end

    loop do

      reader, _ = IO.select([server], nil, nil, Network::TIMEOUT)
      break unless reader

      socket, = server.accept

      processes << fork do
        begin
          file_path = dir.path + "/#{SecureRandom.hex}.ld"
          file = File.open(file_path, 'w+')

          data_counter = 0

          loop do
            reader, _, us = IO.select([socket], nil, [socket], 10)
            break unless reader or us
  
            us.each do |s|
              begin
                s.recv(1, Socket::MSG_OOB)  
              rescue Exception => e
                next
              end
            end

            reader.each do |s|
              data = s.recv(4096)
              exit if data.empty?
              data_counter += data.length
              file.write(data)
            end
          end # end inner loop
        ensure
          file.close if file
          socket.close if socket
        end
      end # end process

      socket.close if socket

    end # end loop do
  ensure
    server.close if server
  end


  def start_tcp_client(port, host, file_name)
    file = File.open(file_name, 'r')
    client = Network::ClientTCP.new(port, host)

    pack_counter = 0
    data_counter = 0

    loop do
      _, writer, = IO.select(nil, [client], nil, 10)

      break unless writer
      data = file.read(4096)

      writer.each do |s|
        return unless data
        sleep(0.0002)
        s.send(data, 0)
        pack_counter += 1
        data_counter += data.length
        puts data_counter

        if pack_counter % 64 == 0
          s.send(MSG, IO::MSG_OOB)
        end
      end
    end
  ensure
    file.close if file
    client.close if client
  end



  def start_udp_client(port, host, file_name)
    file = File.open(file_name, 'r')

    client = Network::ClientUDP.new(port, host)
    client.connect(Socket.sockaddr_in(port, host))

    chunks = file.size / Network::PACK_SIZE
    chunks += 1 unless file.size % Network::PACK_SIZE == 0

    sent = true
    done = false
    seek = -1

    loop do
      wr_arr, rd_arr = sent ? [[client], []] : [[], [client]]
      rs, ws, = IO.select(rd_arr, wr_arr, nil, Network::TIMEOUT)

      break unless rs or ws
      break if sent and done

      data, sent, seek = file.read(Network::PACK_SIZE),
          false, seek + 1 if sent

      ws.each do |s|
        msg = Network::Packet.new(seek: seek, chunks: chunks,
                                  len: data.length, data: data) if data
        done, = data ?
            [false, s.send(msg.to_binary_s, 0)] :
            [true, s.send(Network::FIN, 0)]
      end

      rs.each do |s|
        sent = true if s.recv(3) == Network::ACK
      end
    end
  ensure
    file.close if file
    client.close if client
  end



def start_udp_server(port, host, file_name)
  processes = []
  num =  7

  packet = Network::Packet.new
  mutex = ProcessShared::Mutex.new
  mem = ProcessShared::SharedMemory.new(65535)
  mem.write_object({})

  server = Network::ServerUDP.new(port, host)



  current_path = Dir.pwd
  FileUtils.mkdir_p(current_path + '/received')
  dir = Dir.new("received")


  (1..num).each do
    processes << fork do
      begin
        loop do
          rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
          break unless rs

          rs.each do |s|
            data, who = s.recvfrom_nonblock(Network::PACK_SIZE + 12) rescue nil
            next unless who

            s.send(Network::ACK, 0, who)
            who = who.ip_unpack.to_s
            next if data == Network::FIN

            mutex.synchronize do
              begin
                file = nil
                connections = mem.read_object
                packet.read(data)

                unless connections[who]
                  file_name = dir.path + "/#{SecureRandom.hex}.ld"
                  connections[who] = { chunks: packet.chunks.to_s, file: file_name }
                  file = File.open(file_name, 'w+')
                end

                file = file || File.open(connections[who][:file], 'r+')
                file.seek(packet.seek * Network::PACK_SIZE)
                file.write(packet.data)

                chunks = Integer(connections[who][:chunks]) - 1
                connections[who][:chunks] = chunks.to_s
                if chunks == 0
                  connections.delete(who)
                  next
                end
              ensure
                mem.write_object(connections)
                file.close if file
              end
            end
          end
        end
      ensure
        server.close if server
      end
    end
  end

  Process.waitall
ensure
  server.close if server
end

end