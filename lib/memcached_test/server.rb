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
         #foreach client that connects
         Thread.start(client_connection) do |conn|    
               puts "Connection established #{conn}"
               
               while input = conn.gets.chomp
                  command = input.split(' ')[0] 
                  parameters = input.split(' ').drop(1)
                  
                  case command
                  when "get"
                     resultado = @memcached.get(parameters)
                     if resultado != []
                        resultados.each do |resultado|
                           conn.puts "VALUE #{resultado[0]} #{resultado[1]} #{resultado[3]}\r\n#{resultado[4]}\r\n"
                        end
                        conn.puts "END\r\n"
                     else
                        conn.puts "Couldn't find any value"
                     end

                  when "gets"
                     resultados = @memcached.multiple_get(parameters)
                     if resultado != []
                           resultados.each do |resultado|
                              conn.puts "VALUE #{resultado[0]} #{resultado[1]} #{resultado[3]} #{resultado[4]}\r\n#{resultado[5]}\r\n"
                           end
                           conn.puts "END\r\n"
                     else
                           conn.puts "Couldn't find any value"
                     end

                  when "set"
                     #if parameters[4] == noreply: parameters.slice(4, parameters.length) && delete conn.puts
                     response = @memcached.set(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
                     #if error: response = "ERROR\r\n"
                     conn.puts response

                  when "add"
                     #if parameters[4] == noreply: parameters.slice(4, parameters.length) && delete conn.puts
                     response = @memcached.add(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
                     conn.puts response

                  when "replace"
                     #if parameters[4] == noreply: parameters.slice(4, parameters.length) && delete conn.puts                     
                     response = @memcached.replace(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
                     conn.puts response

                  when "append"
                     #if parameters[4] == noreply: parameters.slice(4, parameters.length) && delete conn.puts
                     response = @memcached.append(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
                     conn.puts response

                  when "prepend"
                     #if parameters[4] == noreply: parameters.slice(4, parameters.length) && delete conn.puts
                     response = @memcached.prepend(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
                     conn.puts response

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
