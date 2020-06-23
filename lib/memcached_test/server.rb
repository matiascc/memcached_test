require 'socket'          
require_relative 'memcached'
 
class Server
   def initialize(socket_address, socket_port)
      @server_socket = TCPServer.open(socket_address, socket_port)
      @memcached = Memcached.new  
   end

   def run
      loop{
         client_connection = @server_socket.accept
         #foreach client that connects
         Thread.start(client_connection) do |conn|    
               puts "Connection established #{conn}"
               
               while input = conn.gets
                  input = input.chomp

                  command = input.split(' ')[0] 
                  parameters = input.split(' ').drop(1)
                  
                  break if command == 'quit'
                  self.process_entry(command, parameters, conn)
               end

               puts "Connection closed #{conn}"
               conn.puts "Closing connection"
               conn.flush
               conn.close
         end
      }
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
            client.puts ("NOT_FOUND\r\n")
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
            client.append ("NOT_FOUND\r\n")
         end

      when "set"
         noreply = false
         if parameters[4] == 'noreply'
            noreply = true
            puts 1
            parameters.delete('noreply')
         end

         response = @memcached.set(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
         client.puts response unless noreply

      when "add"
         noreply = false
         if parameters[4] == 'noreply'
            noreply = true
            parameters.delete('noreply')
         end
         
         response = @memcached.add(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
         client.puts response unless noreply

      when "replace"
         noreply = false
         if parameters[4] == 'noreply'
            noreply = true
            parameters.delete('noreply')
         end

         response = @memcached.replace(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
         client.puts response unless noreply

      when "append"
         noreply = false
         if parameters[4] == 'noreply'
            noreply = true
            parameters.delete('noreply')
         end

         response = @memcached.append(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
         client.puts response unless noreply

      when "prepend"
         noreply = false
         if parameters[4] == 'noreply'
            noreply = true
            parameters.delete('noreply')
         end

         response = @memcached.prepend(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
         client.puts response unless noreply

      when "cas"
         noreply = false
         if parameters[5] == 'noreply'
            noreply = true
            parameters.delete('noreply')
         end

         response = @memcached.cas(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters.slice(5, parameters.length).join(' '))
         client.puts response unless noreply

      when "flush_all"
         response = @memcached.flush_all()
         client.puts response unless parameters[0] == 'noreply'

      else
         client.puts "Invalid command, please retry"
      end
   end

   def purge_expired_keys(interval_time)
      loop{
         sleep(interval_time)
         @memcached.flush_all()          
         puts("----------- Expired keys deleted -----------")
      }
   end

end