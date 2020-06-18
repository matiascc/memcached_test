require 'socket'          
require_relative 'memcached'
 
class Server
   def initialize(socket_address, socket_port)
      @server_socket = TCPServer.open(socket_port, socket_address)
      puts 'Starting server.........'
      @memcached = Memcached.new   
      @break_condition = false
      self.run
      self.purge_expired_keys(1)
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
                  
                  responses = self.process_entry(command, parameters)
                  if responses != nil && responses.is_a?(Array)
                     responses.each do |response|
                        conn.puts(response)
                     end
                  elsif responses != nil && !responses.is_a?(Array)
                     conn.puts(responses)
                  end
               end

               conn.puts "Closing connection"
               conn.flush
               conn.close
         end
      end
   end

   def process_entry(command, parameters)
      case command
      when "get"
         resultados = @memcached.get(parameters)
         responses = []
         if resultados != [] && resultados.is_a?(Array)
            resultados.each do |resultado|
               responses.append ("VALUE #{resultado[0]} #{resultado[1]} #{resultado[3]}\r\n#{resultado[4]}\r\n")
            end
            responses.append ("END\r\n")
         elsif resultados != [] && !resultados.is_a?(Array)
            responses.append ("VALUE #{resultados[0]} #{resultados[1]} #{resultados[3]}\r\n#{resultados[4]}\r\n")
            responses.append ("END\r\n")
         else
            responses.append ("Couldn't find any value")
         end
         return responses 

      when "gets"
         resultados = @memcached.gets(parameters)
         responses = []
         if resultados != [] && resultados.is_a?(Array)
               resultados.each do |resultado|
                  responses.append ("VALUE #{resultado[0]} #{resultado[1]} #{resultado[3]} #{resultado[4]}\r\n#{resultado[5]}\r\n")
               end
               responses.append ("END\r\n")
         elsif resultados != [] && !resultados.is_a?(Array)
            responses.append ("VALUE #{resultados[0]} #{resultados[1]} #{resultados[3]} #{resultado[4]}\r\n#{resultados[5]}\r\n")
            responses.append ("END\r\n")
         else
               responses.append ("Couldn't find any value")
         end
         return responses

      when "set"
         if parameters[4] == 'noreply'
            @memcached.set(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length)) 
            return nil
         else
            response = @memcached.set(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            return response
         end

      when "add"
         if parameters[4] == 'noreply'
            @memcached.add(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length)) 
            return nil
         else
            response = @memcached.add(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            return response
         end

      when "replace"
         if parameters[4] == 'noreply'
            @memcached.replace(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length)) 
            return nil
         else
            response = @memcached.replace(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            return- response
         end

      when "append"
         if parameters[4] == 'noreply'
            @memcached.append(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length)) 
            return nil
         else
            response = @memcached.append(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            return response
         end

      when "prepend"
         if parameters[4] == 'noreply'
            @memcached.prepend(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(5, parameters.length)) 
            return nil
         else
            response = @memcached.prepend(parameters[0], parameters[1], parameters[2], parameters[3], parameters.slice(4, parameters.length).join(' '))
            return response
         end

      when "cas"
         if parameters[5] == 'noreply'
            @memcached.cas(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters.slice(6, parameters.length)) 
            return nil
         else
            response = @memcached.cas(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters.slice(5, parameters.length).join(' '))
            return response
         end

      when "flush_all"
         response = @memcached.flush_all()
         return response unless parameters[0] == 'noreply'

      when "quit"
         @break_condition = true

      else
         return "Invalid command, please retry"
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

Server.new(11211, "localhost")
