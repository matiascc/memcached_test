require 'socket'          
require_relative 'memcached'
require_relative 'commands_format'
 
module MemcachedTest
   class Server
      attr_reader :server_socket

      def initialize(socket_address, socket_port)
         @server_socket = TCPServer.open(socket_address, socket_port)
         @memcached = Memcached.new  
      end

      def run
         loop{
            client_connection = @server_socket.accept
            Thread.start(client_connection) do |conn|    
                  puts "Connection established #{conn}"
                  
                  while input = conn.gets
                     input = input.chomp
                     
                     break if input == 'quit'
                     self.process_entry(input, conn)
                  end

                  puts "Connection closed #{conn}"
                  conn.puts "Closing connection"
                  conn.flush
                  conn.close
            end
         }
      end

      def process_entry(input, client)
         case input
         when Commands_format.get
            keys = $~['keys'].split(' ')
            resultados = @memcached.get(keys)
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

         when Commands_format.gets
            keys = $~['keys'].split(' ')
            resultados = @memcached.gets(keys)
            if resultados != [] && resultados.is_a?(Array)
                  resultados.each do |resultado|
                     client.puts ("VALUE #{resultado[0]} #{resultado[1]} #{resultado[3]} #{resultado[4]}\r\n#{resultado[5]}\r\n")
                  end
                  client.puts ("END\r\n")
            elsif resultados != [] && !resultados.is_a?(Array)
               client.puts ("VALUE #{resultados[0]} #{resultados[1]} #{resultados[3]} #{resultado[4]}\r\n#{resultados[5]}\r\n")
               client.puts ("END\r\n")
            else
               client.puts ("NOT_FOUND\r\n")
            end

         when Commands_format.set
            key, flags, exptime, bytes, noreply, data = self.pass_parameters($~)
            response = @memcached.set(key, flags, exptime, bytes, data)
            client.puts response unless noreply

         when Commands_format.add
            key, flags, exptime, bytes, noreply, data = self.pass_parameters($~)
            response = @memcached.add(key, flags, exptime, bytes, data)
            client.puts response unless noreply

         when Commands_format.replace
            key, flags, exptime, bytes, noreply, data = self.pass_parameters($~)
            response = @memcached.replace(key, flags, exptime, bytes, data)
            client.puts response unless noreply

         when Commands_format.append
            key, flags, exptime, bytes, noreply, data = self.pass_parameters($~)
            response = @memcached.append(key, flags, exptime, bytes, data)
            client.puts response unless noreply

         when Commands_format.prepend
            key, flags, exptime, bytes, noreply, data = self.pass_parameters($~)
            response = @memcached.prepend(key, flags, exptime, bytes, data)
            client.puts response unless noreply

         when Commands_format.cas
            key, flags, exptime, bytes, noreply, data = self.pass_parameters($~)
            cas = $~['cas']
            response = @memcached.cas(key, flags, exptime, bytes, cas, data)
            client.puts response unless noreply

         when Commands_format.flush_all
            response = @memcached.flush_all()
            client.puts response if $~['noreply'].nil?

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

      def pass_parameters(reg_exp)
         key = reg_exp['key']
         flags = reg_exp['flags']
         exptime = reg_exp['exptime']
         bytes = reg_exp['bytes']
         noreply = !reg_exp['noreply'].nil?
         data = reg_exp['data']
         return key, flags, exptime, bytes, noreply, data
      end
   end
end