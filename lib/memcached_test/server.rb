require 'socket'          
require_relative 'memcached'
 
class Server
   def initialize(socket_address, socket_port)
      @server_socket = TCPServer.open(socket_address, socket_port)
      puts 'Starting server.........'
      @memcached = Memcached.new   
      @break_condition = false
      self.run
      self.purge_expired_keys(5)
   end

   def run
      while !@break_condition
         client_connection = @server_socket.accept
         #foreach client that connects
         Thread.start(client_connection) do |conn|    
               puts "Connection established #{conn}"
               
               while input = conn.gets.chomp
                  command = input.split(' ')[0] 
                  parameters = input.split(' ').drop(1)
                  
                  self.process_entry(command, parameters, conn)
               end

               conn.puts "Closing connection"
               conn.flush
               conn.close
         end
      end
   end

   def process_entry(command, parameters, client)
      case command
      when "get"
         resultados = @memcached.get(parameters)
         if resultados != [] && resultados.is_a?(Array)
            resultados.each do |resultado|
               client.puts ("VALUE #{resultado[0]} #{resultado[1]} #{resultado[3]}\r\n#{resultado[4]}\r\n")
            end
            client.puts ("END\r\n")
         elsif resultados != [] && !resultados.is_a?(Array)
            client.puts ("VALUE #{resultados[0]} #{resultados[1]} #{resultados[3]}\r\n#{resultados[4]}\r\n")
            client.puts ("END\r\n")
         else
            client.puts ("Couldn't find any value")
         end

      when "gets"
         resultados = @memcached.gets(parameters)
         if resultados != [] && resultados.is_a?(Array)
               resultados.each do |resultado|
                  client.puts ("VALUE #{resultado[0]} #{resultado[1]} #{resultado[3]} #{resultado[4]}\r\n#{resultado[5]}\r\n")
               end
               client.puts ("END\r\n")
         elsif resultados != [] && !resultados.is_a?(Array)
            client.puts ("VALUE #{resultados[0]} #{resultados[1]} #{resultados[3]} #{resultado[4]}\r\n#{resultados[5]}\r\n")
            client.puts ("END\r\n")
         else
            client.append ("Couldn't find any value")
         end

      when "set"
         if parameters[4] == 'noreply'
            @memcached.set(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length))
         else
            response = @memcached.set(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            client.puts response
         end

      when "add"
         if parameters[4] == 'noreply'
            @memcached.add(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length))
         else
            response = @memcached.add(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            client.puts response
         end

      when "replace"
         if parameters[4] == 'noreply'
            @memcached.replace(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length)) 
         else
            response = @memcached.replace(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            client.puts response
         end

      when "append"
         if parameters[4] == 'noreply'
            @memcached.append(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length)) 
         else
            response = @memcached.append(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            client.puts response
         end

      when "prepend"
         if parameters[4] == 'noreply'
            @memcached.prepend(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length)) 
         else
            response = @memcached.prepend(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            client.puts response
         end

      when "cas"
         if parameters[5] == 'noreply'
            @memcached.cas(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters.slice(6, parameters.length)) 
         else
            response = @memcached.cas(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters.slice(5, parameters.length).join(' '))
            client.puts response
         end

      when "flush_all"
         response = @memcached.flush_all()
         client.puts response unless parameters[0] == 'noreply'

      when "quit"
         @break_condition = true

      else
         client.puts "Invalid command, please retry"
      end
   end

   def purge_expired_keys(interval_time)
      loop{
         sleep(interval)
         @memc.check_exptimes()          
         puts("----------- Expired keys deleted -----------")
      }
   end

end

server = Server.new('localhost', 11211)