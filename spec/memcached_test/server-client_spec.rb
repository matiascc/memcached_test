require 'memcached_test/server'
require 'memcached_test/client'

include MemcachedTest

describe Server do
  before(:example) do
    @server = Server.new('localhost', 11211)
    Thread.new { @server.run() }
    sleep 1
    @client = Client.new('localhost', 11211)
  end

  after(:example) do
    @server.server_socket.close
    @client.socket.close  
  end

  describe '.set' do
    context 'given the correct parameters' do
      it "set a value asociated to a key that doesn't exist" do
          response = @client.set('test', 10, 100, 10, 'Data')
          expect(response).to eql("STORED\r\n")
      end
      it "set a value asociated to a key that exists" do  
          @client.set("key", 10, 500, 20, "Data to be stored")
          response = @client.set("key", 10, 500, 20, "New data to be stored")
          expect(response).to eql("STORED\r\n")
      end
      it "set a value but use noreply" do  
        response = @client.set("key", 10, 500, 20, 'noreply', "Data to be stored")
        expect(response).to eql(nil)
      end
    end
  end
 
  describe '.get' do
    context 'given the correct parameters' do
      it "get value asociated to a key after a set" do
          @client.set('test', 10, 100, 10, 'Data')
          response = @client.get('test')
          expect(response).to eql(["VALUE test 10 10\r\n", "Data\r\n", "END\r\n"])
      end
      it "get a values asociated to 2 keys" do  
        @client.set("key", 10, 0, 10, "Data to be stored")
        @client.set("key2", 20, 0, 10, "Data to be stored2")

        return_gets = @client.gets(["key", "key2"])
        expect(return_gets).to eql(["VALUE key 10 10 1\r\n", "Data to be stored\r\n", "VALUE key2 20 10 1\r\n", "Data to be stored2\r\n", "END\r\n"])
      end
    end
    context "given a key that doesn't exist" do
      it "get an empty array" do  
          return_get = @client.get(["keyy"])
          expect(return_get).to eql(["NOT_FOUND\r\n"])
      end
    end
  end

  describe '.gets' do
    context 'given the correct parameters' do
      it "gets value asociated to a key after a set" do
          @client.set('test', 10, 100, 10, 'Data')
          response = @client.gets('test')
          expect(response).to eql(["VALUE test 10 10 1\r\n", "Data\r\n", "END\r\n"])
      end
      it "get a values asociated to 2 keys" do  
          @client.set("key", 10, 0, 10, "Data to be stored")
          @client.set("key2", 20, 0, 10, "Data to be stored2")

          response = @client.gets(["key", "key2"])
          expect(response).to eql(["VALUE key 10 10 1\r\n", "Data to be stored\r\n", "VALUE key2 20 10 1\r\n", "Data to be stored2\r\n", "END\r\n"])
      end
    end
    context "given a key that doesn't exist" do
      it "get an empty array" do  
        response = @client.gets(["keyy"])
        expect(response).to eql(["NOT_FOUND\r\n"])
      end
    end
  end

  describe '.add' do
    context 'given the correct parameters' do
      it "add a value asociated to a key that doesn't exist" do
        response = @client.add('test', 10, 100, 10, 'data')
        expect(response).to eql("STORED\r\n")
      end
      it "get value asociated to a key after an add" do
        @client.add('test', 10, 100, 10, 'Data')
        response = @client.get('test')
        expect(response).to eql(["VALUE test 10 10\r\n", "Data\r\n", "END\r\n"])
      end
      it "add a value asociated to a key that doesn't exist" do  
        response = @client.add("key", 10, 500, 20, "Data to be stored")
          expect(response).to eql("STORED\r\n")
      end
      it "add a value asociated to a key that exists" do
          @client.add("key", 10, 500, 20, "Data to be stored")
          response = @client.add("key", 10, 500, 20, "Data to be stored")
          expect(response).to eql("NOT_STORED\r\n")
      end
      it "add a value but use noreply" do  
        response = @client.add("key", 10, 500, 20, 'noreply', "Data to be stored")
        expect(response).to eql(nil)
      end
    end
  end

  describe '.replace' do
    context 'given the correct parameters' do
      it "replace a values asociated to a key" do
        @client.set('test', 10, 100, 10, 'Data')
        @client.replace('test', 10, 100, 10, 'New Data')
        response = @client.get('test')
        expect(response).to eql(["VALUE test 10 10\r\n", "New Data\r\n", "END\r\n"])
      end
      it "replace a value asociated to a key that exists" do  
          @client.set("key", 10, 500, 20, "Data to be stored")
          response = @client.replace("key", 10, 500, 20, "New data to be stored")
          expect(response).to eql("STORED\r\n")
      end
      it "replace a value asociated to a key that doesn't exist" do  
          response = @client.replace("key", 10, 500, 20, "New data to be stored")
          expect(response).to eql("NOT_STORED\r\n")
      end
      it "replace a value but use noreply" do  
        @client.set("key", 10, 500, 20, "Data to be stored")
        response = @client.replace("key", 10, 500, 20, 'noreply', "New data to be stored")
        expect(response).to eql(nil)
      end
    end
  end

  describe '.prepend' do
    context 'given the correct parameters' do
      it "prepend data asociated to a key" do
        @client.set('test', 10, 100, 10, 'data')
        @client.prepend('test', 10, 100, 10, 'New ')
        response = @client.get('test')
        expect(response).to eql(["VALUE test 10 10\r\n", "New data\r\n", "END\r\n"])
      end
      it "prepend a key that exists" do  
          @client.set("key", 10, 500, 20, "to be stored")
          return_set = @client.prepend("key", 10, 500, 20, "Data ")
          expect(return_set).to eql("STORED\r\n" )
      end
      it "prepend a key that doesn't exist" do
            return_set = @client.prepend("key", 10, 500, 20, " stored")
            expect(return_set).to eql("NOT_STORED\r\n")
      end
      it "prepend a value but use noreply" do  
        @client.set("key", 10, 500, 20, "Data to be stored")
        response = @client.prepend("key", 10, 500, 20, 'noreply', "New data to be stored")
        expect(response).to eql(nil)
      end
    end
  end

  describe '.append' do
    context 'given the correct parameters' do
      it "append data asociated to a key" do
        @client.add('test', 10, 100, 10, 'New')
        @client.append('test', 10, 100, 10, ' data')
        response = @client.get('test')
        expect(response).to eql(["VALUE test 10 10\r\n", "New data\r\n", "END\r\n"])
      end
      it "append a key that exists" do 
          @client.set("key", 10, 500, 20, "Data to be")
          return_set = @client.append("key", 10, 500, 20, " stored")
          expect(return_set).to eql("STORED\r\n")
      end
      it "append a key that doesn't exist" do
            return_set = @client.append("key", 10, 500, 20, " stored")
            expect(return_set).to eql("NOT_STORED\r\n")
      end
      it "append a value but use noreply" do  
        @client.set("key", 10, 500, 20, "Data to be stored")
        response = @client.append("key", 10, 500, 20, 'noreply', "New data to be stored")
        expect(response).to eql(nil)
      end
    end
  end

  describe '.cas' do
    context 'given the correct parameters' do
      it "cas and then get a value asociated to a key that doesn't exist" do
        @client.set("test", 10, 100, 10, "Data to be stored")
        @client.cas('test', 10, 100, 10, 1, "New data to be stored")
        response = @client.gets('test')
        expect(response).to eql(["VALUE test 10 10 1\r\n", "New data to be stored\r\n", "END\r\n"])
      end
      it "set a value to a key that exists with a correct cas_num = 1" do  
        @client.set("key", 10, 500, 20, "Data to be stored")
        return_set = @client.cas("key", 10, 500, 20, 1, "New data to be stored")
        expect(return_set).to eql("STORED\r\n")
      end
      it "set a value to a key that exists with a correct cas_num > 1" do  
        @client.set("key", 10, 500, 20, "Data to be stored")
        @client.set("key", 10, 500, 20, "New data to be stored")
        return_set = @client.cas("key", 10, 500, 20, 2, "New data to be stored 2")
        expect(return_set).to eql("STORED\r\n")
      end
      it "set a value to a key that exists with an incorrect cas_num" do  
        @client.set("key", 10, 500, 20, "Data to be stored")
        return_set = @client.cas("key", 10, 500, 20, 3, "New data to be stored")
        expect(return_set).to eql("EXISTS\r\n")
      end
      it "cas a value asociated to a key that doesn't exist" do  
        return_set = @client.cas("key", 10, 500, 20, 2, "New data to be stored")
        expect(return_set).to eql("NOT_FOUND\r\n")
      end
      it "cas a value but use noreply" do  
        @client.set("key", 10, 500, 20, "Data to be stored")
        response = @client.cas("key", 10, 500, 20, 1, 'noreply', "New data to be stored")
        expect(response).to eql(nil)
      end
    end
  end
end
