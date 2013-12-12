require 'socket'
require 'securerandom'
require 'fileutils'
require '../SPOLKS_LIB/Sockets/network.rb'

module Transmitter
  MSG = '*'
  module_function

  def start_tcp_server(port, host, file_name)
    threads = []
    mutex = Mutex.new

    current_path = Dir.pwd
    FileUtils.mkdir_p(current_path + '/received')
    dir = Dir.new("received")


    server = Network::ServerTCP.new(port, host)

    loop do
      reader, _ = IO.select([server], nil, nil, Network::TIMEOUT)
      break unless reader

      socket, = server.accept

      threads << Thread.new do
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
              return if data.empty?
              data_counter += data.length
              file.write(data)
            end
          end

        ensure
          file.close if file
          socket.close if socket
          mutex.synchronize do
            threads.delete(Thread.current)
          end
        end
      end

    end

    mutex.synchronize do
      threads.each(&:join)
    end

  ensure
    server.close if server
    mutex.synchronize do
      threads.each(&:exit)
    end
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

    chunks = file.size / 4096
    chunks += 1 unless file.size % 4096 == 0

    sent = true
    done = false
    seek = -1

    loop do
      wr_arr, rd_arr = sent ? [[client], []] : [[], [client]]
      rs, ws, = IO.select(rd_arr, wr_arr, nil, Network::TIMEOUT)

      break unless rs or ws
      break if sent and done

      data, sent, seek = file.read(4096),
          false, seek + 1 if sent

      ws.each do |s|
        msg = Network::Packet.new(seek: seek, chunks: chunks, len: data.length, data: data) if data
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
    threads = []
    clients = {}
    mutex = Mutex.new
    num = 7

    current_path = Dir.pwd
    FileUtils.mkdir_p(current_path + '/received')
    dir = Dir.new("received")

    packet = Network::Packet.new
    server = Network::ServerUDP.new(port, host)

    (1..num).each do
      threads << Thread.new do
        loop do
          rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
          break unless rs

          rs.each do |s|
            data, who = s.recvfrom_nonblock(4096 + 12) rescue nil
            next unless who

            s.send(Network::ACK, 0, who)
            who = who.ip_unpack.to_s
            next if data == Network::FIN

            mutex.synchronize do
              packet.read(data)
              unless clients[who]
                clients[who] = { file: File.open(dir.path + "/#{SecureRandom.hex}.ld", 'w+'), chunks: packet.chunks }
              end

              clients[who][:file].seek(packet.seek * 4096)
              clients[who][:file].write(packet.data)
              clients[who][:chunks] -= 1

              if clients[who][:chunks] == 0
                clients[who][:file].close
                clients.delete(who)
                next
              end
            end
          end
        end
      end
    end

    threads.each(&:run)
    threads.each(&:join)
  ensure
    server.close if server
    threads.each(&:exit)
    p clients
    clients.each do |key, hash|
      hash[:file].close if file
    end
  end

end