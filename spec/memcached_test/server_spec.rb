require 'rspec/autorun'
require 'memcached_test/server'

describe memcached_test::Server do
    it "conect to the server" do  
        server = Server.new(11511,localhost)
        expect(server.close).to be_successful
    end
end