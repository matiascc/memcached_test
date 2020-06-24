require_relative '../lib/memcached_test/client.rb'

class Client_test_3
    def initialize(address, port)
        @cli = MemcachedTest::Client.new( address, port )
        self.test()
    end

    def test()
        response_1 = @cli.add('test', 10, 100, 10, 'Data')
        response_2 = @cli.replace('test', 10, 100, 10, "New data")
        response_3 = @cli.get('test')

        puts response_1
        puts response_2
        response_3.each do |item|
            puts item
        end
    end
end

Client_test_3.new( 'localhost', 11211 )