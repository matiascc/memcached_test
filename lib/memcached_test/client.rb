require 'socket'    

module MemcachedTest
   class Client
      attr_reader :socket
      
      def initialize(host, port)
         @socket = TCPSocket.open(host, port)
      end

      def send_request
         puts "Please enter a command:"
         begin
            Thread.new do
                  loop do
                     @socket.puts $stdin.gets.chomp
                  end
               rescue IOError => e
                  puts "#{e.class}: #{e.message}"
                  @socket.close
            end
         end
      end

      def listen_response
         begin
            Thread.new do
                  loop do
                     response = @socket.gets.chomp
                     puts "> #{response}"

                     if response == 'Closing connection'  
                        @socket.close
                        break
                     end
                  end
               rescue IOError => e
                  puts "#{e.class}: #{e.message}"
                  @socket.close
            end
         end
      end

      def get(*keys)
         @socket.puts("get #{keys.join(' ')}")
         items = []

         loop do
            response = @socket.gets()
            items.append response
            case response
               when "NOT_FOUND\r\n"
                  break
               when "END\r\n"
                  break
            end
         end

         return items
      end

      def gets(*keys)
         @socket.puts("gets #{keys.join(' ')}")
         items = []

         loop do
            response = @socket.gets()
            items.append response
            case response
               when "NOT_FOUND\r\n"
                  break
               when "END\r\n"
                  break
            end
         end

         return items
      end
      
      def set(key, flags, exptime, bytes, noreply = '', data)
         if noreply == ''
            @socket.puts("set #{key} #{flags} #{exptime} #{bytes}")
            @socket.puts("#{data}")
         else
            @socket.puts("set #{key} #{flags} #{exptime} #{bytes} #{noreply}")
            @socket.puts("#{data}")
         end
         return @socket.gets() unless noreply == 'noreply'
      end

      def add(key, flags, exptime, bytes, noreply = '', data)
         if noreply == ''
            @socket.puts("add #{key} #{flags} #{exptime} #{bytes}") 
            @socket.puts("#{data}")
         else
            @socket.puts("add #{key} #{flags} #{exptime} #{bytes} #{noreply}")
            @socket.puts("#{data}")
         end
         return @socket.gets() unless noreply == 'noreply'
      end

      def replace(key, flags, exptime, bytes, noreply = '', data)
         if noreply == ''
            @socket.puts("replace #{key} #{flags} #{exptime} #{bytes}")  
            @socket.puts("#{data}")
         else
            @socket.puts("replace #{key} #{flags} #{exptime} #{bytes} #{noreply}")  
            @socket.puts("#{data}")
         end
         return @socket.gets() unless noreply == 'noreply'
      end

      def append(key, bytes, noreply = '', data)
         if noreply == ''
            @socket.puts("append #{key} #{bytes}")
            @socket.puts("#{data}")
         else
            @socket.puts("append #{key} #{bytes} #{noreply}")
            @socket.puts("#{data}")
         end 
         return @socket.gets() unless noreply == 'noreply'
      end

      def prepend(key, bytes, noreply = '', data)
         if noreply == ''
            @socket.puts("prepend #{key} #{bytes}")
            @socket.puts("#{data}")
         else
            @socket.puts("prepend #{key} #{bytes} #{noreply}")
            @socket.puts("#{data}")
         end 
         return @socket.gets() unless noreply == 'noreply'
      end

      def cas(key, flags, exptime, bytes, cas, noreply = '', data)
         if noreply == ''
            @socket.puts("cas #{key} #{flags} #{exptime} #{bytes} #{cas}")
            @socket.puts("#{data}")
         else
            @socket.puts("cas #{key} #{flags} #{exptime} #{bytes} #{cas} #{noreply}")
            @socket.puts("#{data}")
         end
         return @socket.gets() unless noreply == 'noreply'
      end

   end
end
