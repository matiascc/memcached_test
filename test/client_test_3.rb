require_relative '../lib/memcached_test/client.rb'

class Client_test_3
    def initialize(address, port)
        @cli = MemcachedTest::Client.new( address, port )
        self.test()
    end

    def test()
        response_1 = @cli.add('test_1', 10, 100, 10, 'noreply', 'Data')
        response_2 = @cli.replace('test_1', 10, 100, 10, 'noreply', "New data")
        response_3 = @cli.add('test_2', 10, 100, 10, 'Data')
        response_4 = @cli.cas('test_2', 10, 100, 10, 1, "New data")
        response_5 = @cli.get('test_1')
        response_6 = @cli.gets('test_2')

        puts response_1
        puts response_2
        puts response_3
        puts response_4
        response_5.each do |item|
            puts item
        end
        response_6.each do |item|
            puts item
        end
    end
end

Client_test_3.new( 'localhost', 11211 )