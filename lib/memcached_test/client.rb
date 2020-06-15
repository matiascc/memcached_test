require 'socket'            

class Client
    def initialize(socket)
       @socket = socket
       @request_object = send_request
       @response_object = listen_response
 
       @request_object.join # will send the request to server
       @response_object.join # will receive response from server
    end
 
    def send_request
       puts "Please enter your username to establish a connection..."
       begin
          Thread.new do
             loop do
                message = $stdin.gets.chomp
                @socket.puts message
             end
          end
       rescue IOError => e
          puts e.message
          # e.backtrace
          @socket.close
       end
 
    end
 
    def listen_response
       begin
          Thread.new do
             loop do
                response = @socket.gets.chomp
                puts "#{response}"
                if response.eql?'quit'
                   @socket.close
                end
             end
          end
       rescue IOError => e
          puts e.message
          # e.backtrace
          @socket.close
       end
    end
 end
 
 socket = TCPSocket.open( "localhost", 11211 )
 Client.new( socket )

 
#msg = $stdin.gets.chomp # $stdin is an object that's always present and manages user input from the console
#socket.puts( msg ) # take what you entered and send it via TCP to the socket file
#puts socket.gets.chomp # wait for more content to appear in the socket and print it to the console
 
#while line = socket.gets  
#    puts line.chop      
#end
