require 'socket'          
require_relative 'memcached'
 
class Server
   def initialize(socket_address, socket_port)
      @server_socket = TCPServer.open(socket_port, socket_address)
      puts 'Starting server.........'
      @memcached = Memcached.new    
      self.run
   end

   def run
      loop{
         client_connection = @server_socket.accept
         Thread.start(client_connection) do |conn|
               puts "Connection established #{conn}"
               
               while input = conn.gets.chomp #.to_sym
                  command = input.split(' ')[0] 
                  parameters = input.split(' ').drop(1)
                  
                  case command
                  when "get"
                     resultado = @memcached.get(parameters[0])
                     if resultado != nil
                           conn.puts "Key: #{resultado[0]}, Flags: #{resultado[1]}, Exptime: #{resultado[2]}, Bytes: #{resultado[3]}, Data: #{resultado[4]}"
                     else
                           conn.puts "Couldn't find value"
                     end
                  when "gets"
                     resultados = @memcached.multiple_get(parameters)
                     if resultado != []
                           resultados.each do |resultado|
                              conn.puts "Key: #{resultado[0]}, Flags: #{resultado[1]}, Exptime: #{resultado[2]}, Bytes: #{resultado[3]}, Data: #{resultado[4]}"
                           end
                     else
                           conn.puts "Couldn't find any value"
                     end
                  when "set"
                     @memcached.set(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
                     conn.puts "Success on set"
                  when "add"
                     conn.puts "You're doing a add, and saying #{parameters.join(' ')}"
                  when "quit"
                     break
                  else
                     conn.puts "Invalid command, please retry"
                  end
               end

               conn.puts "Closing connection"
               conn.flush
               conn.close
         end
      }
   end
end

Server.new(11211, "localhost")
