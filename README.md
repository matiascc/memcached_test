# MemcachedTest
A test of Memcached server implementation, using TCP/IP socket.
This was done as part of a [coding challenge](https://github.com/moove-it/coding-challenges/blob/master/ruby.md).

## Installation

``` shell
gem install memcached_test
```

## Usage

#### Server
A class that creates a TCPServer to connect to and interact with the Memcached class to send or request the data.
The Memcached class manages the storage and retrieval of the data in the cache, complying with the memcached protocol.

```ruby
require 'memcached_test'

server = MemcachedTest::Server.new('localhost', 11211)

main = Thread.new {
    server.run()
}

#Executes the process that purge expired keys every 10 seconds
Thread.new {
    server.purge_expired_keys(10)
}

main.join()
```

#### Client
A class that connects to a TCPServer and interacts with it by commands.

```ruby
require 'memcached_test'

cli = MemcachedTest::Client.new('localhost', 11211)

#Invoke here the functions to interact with the server
#For example:
cli.set('test', 0, 100, 13, 'Data to store')
cli.get('test')
```

## Try it in the terminal
To try the server and a console client execute:

#### For the server:
``` shell
memcached_test_server <host> <port>
```
For example:
``` shell
memcached_test_server localhost 11211
```

#### For the client:
``` shell
memcached_test_client <host> <port>
```
Using the same host and port of the server.

For example:
``` shell
memcached_test_client localhost 11211
```
And finally try the commands in the client console.

## Testing
To test the commands execute inside the main folder: 
``` shell
rspec .\spec\memcached_test\memcached_spec.rb
rspec .\spec\memcached_test\server-client_spec.rb
```

In the jmeter folder you can find the test plan (Test Plan.jmx). The result of executing it are already in the same folder (loadtest.csv and HTMLreport folder).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).