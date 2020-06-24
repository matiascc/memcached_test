require_relative '../lib/memcached_test/client.rb'

class Client_test_2
    def initialize(address, port)
        @cli = MemcachedTest::Client.new( address, port )
        self.test()
    end

    def test()
        response_1 = @cli.set('test', 10, 100, 10, '_')
        response_2 = @cli.prepend('test', 10, 100, 10, "test")
        response_3 = @cli.append('test', 10, 100, 10, "data")
        response_4 = @cli.get('test')

        puts response_1
        puts response_2
        puts response_3
        response_4.each do |item|
            puts item
        end
    end
end

Client_test_2.new( 'localhost', 11211 )