require_relative '../lib/memcached_test/client.rb'

class Client_test_1
    def initialize(address, port)
        @cli = MemcachedTest::Client.new( address, port )
        self.test()
    end

    def test()
        @cli.set('test', 10, 100, 10, 'noreply', 'Data')
        response_2 = @cli.set('test2', 10, 100, 10, 'Data 2')
        response_3 = @cli.get('test', 'test2', 'test3')

        puts response_2
        response_3.each do |item|
            puts item
        end
    end
end

Client_test_1.new( 'localhost', 11211 )