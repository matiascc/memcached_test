require 'socket'               
 
 class Server
    def initialize(socket_address, socket_port)
       @server_socket = TCPServer.open(socket_port, socket_address)
 
       @connections_details = Hash.new
       @connected_clients = Hash.new
 
       @connections_details[:server] = @server_socket
       @connections_details[:clients] = @connected_clients
 
       puts 'Starting server.........'
       run
    end

    def run
       loop{
          client_connection = @server_socket.accept
          Thread.start(client_connection) do |conn| # open thread for each accepted connection
             conn_name = conn.gets.chomp.to_sym
             if(@connections_details[:clients][conn_name] != nil) # avoid connection if user exits
                conn.puts "This username already exist"
                conn.puts "quit"
                conn.kill self
             end
 
             puts "Connection established #{conn_name} => #{conn}"
             @connections_details[:clients][conn_name] = conn
             conn.puts "Connection established successfully #{conn_name} => #{conn}, you may continue with chatting....."
 
          end
       }.join

       client.puts "Closing the connection."
       client.close 
    end
end

Server.new( 11211, "localhost" )