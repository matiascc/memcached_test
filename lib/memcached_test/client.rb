require 'socket'    

class Client
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
         end
      end
   end

   def listen_response
      begin
         Thread.new do
               loop do
                  response = @socket.gets.chomp
                  puts "> #{response}"
                  if response.eql?'quit'
                  @socket.close
                  end
               end
         end
      end
   end

   def set(key, flags, exptime, bytes, data)
      @socket.puts("set #{key} #{flags} #{exptime} #{bytes} #{data}")  
      return @socket.gets()
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

   def add(key, flags, exptime, bytes, data)
      @socket.puts("add #{key} #{flags} #{exptime} #{bytes} #{data}")  
      return @socket.gets()
   end

   def replace(key, flags, exptime, bytes, data)
      @socket.puts("replace #{key} #{flags} #{exptime} #{bytes} #{data}")  
      return @socket.gets()
   end

   def append(key, flags, exptime, bytes, data)
      @socket.puts("append #{key} #{flags} #{exptime} #{bytes} #{data}")  
      return @socket.gets()
   end

   def prepend(key, flags, exptime, bytes, data)
      @socket.puts("prepend #{key} #{flags} #{exptime} #{bytes} #{data}")  
      return @socket.gets()
   end

   def cas(key, flags, exptime, bytes, cas, data)
      @socket.puts("cas #{key} #{flags} #{exptime} #{bytes} #{cas} #{data}")  
      return @socket.gets()
   end

end

