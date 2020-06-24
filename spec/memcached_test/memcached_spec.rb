require 'memcached_test/memcached'

describe MemcachedTest::Memcached do
    before(:example) do
        @mem = MemcachedTest::Memcached.new
    end

    describe ".set" do
        context "given the correct parameters" do
            it "set a value asociated to a key that doesn't exist" do  
                return_set = @mem.set("key", 10, 500, 20, "Data to be stored")
                expect(return_set).to eql("STORED\r\n" )
            end
            it "set a value asociated to a key that exists" do  
                @mem.set("key", 10, 500, 20, "Data to be stored")
                return_set = @mem.set("key", 10, 500, 20, "New data to be stored")
                expect(return_set).to eql("STORED\r\n" )
            end
            it "correctly set cas = 1" do  
                @mem.set("key", 10, 500, 20, "Data to be stored")
                expect(@mem.gets(["key"])[0][4]).to eql(1)
            end
            it "correctly set cas > 1" do  
                @mem.set("key", 10, 500, 20, "Data to be stored")
                @mem.set("key", 10, 500, 20, "New data to be stored")
                @mem.set("key", 10, 500, 20, "New data to be stored 2")
                expect(@mem.gets(["key"])[0][4]).to eql(3)
            end
        end
    end
    
    describe ".get" do
        context "given a key that exists" do
            it "get a value asociated to a key" do  
                @mem.set("key", 10, 0, 20, "Data to be stored")
    
                return_get = @mem.get(["key"])
                expect(return_get).to eql([["key", 10, nil, 20, "Data to be stored"]])
            end
        end
        context "given a key that doesn't exist" do
            it "get an empty array" do  
                return_get = @mem.get(["key"])
                expect(return_get).to eql([])
            end
        end
    end
    
    describe ".gets" do
        context "given multiple keys that exists" do
            it "get a values asociated to 2 keys" do  
                @mem.set("key", 10, 0, 10, "Data to be stored")
                @mem.set("key2", 20, 0, 10, "Data to be stored2")
    
                return_gets = @mem.gets(["key", "key2"])
                expect(return_gets).to eql([["key", 10, nil, 10, 1, "Data to be stored"],["key2", 20, nil, 10, 1, "Data to be stored2"]])
            end
        end
        context "given a key that doesn't exist" do
            it "get an empty array" do  
                return_gets = @mem.gets(["key"])
                expect(return_gets).to eql([])
            end
        end
    end
    
    describe ".add" do
        context "given the correct parameters" do
            it "set a value asociated to a key that doesn't exist" do  
                return_set = @mem.add("key", 10, 500, 20, "Data to be stored")
                expect(return_set).to eql("STORED\r\n")
            end
            it "set a value asociated to a key that exists" do
                @mem.add("key", 10, 500, 20, "Data to be stored")
                return_set = @mem.add("key", 10, 500, 20, "Data to be stored")
                expect(return_set).to eql("NOT_STORED\r\n")
            end
        end
    end
    
    describe ".replace" do
        context "given the correct parameters" do
            it "set a value asociated to a key that exists" do  
                @mem.set("key", 10, 500, 20, "Data to be stored")
                return_set = @mem.replace("key", 10, 500, 20, "New data to be stored")
                expect(return_set).to eql("STORED\r\n")
            end
            it "set a value asociated to a key that doesn't exist" do  
                return_set = @mem.replace("key", 10, 500, 20, "New data to be stored")
                expect(return_set).to eql("NOT_STORED\r\n")
            end
        end
    end
    
    describe ".append" do
        context "given a key that exists" do
            it "correctly make the operation" do  
                @mem.set("key", 10, 500, 20, "Data to be")
                return_set = @mem.append("key", 10, 500, 20, " stored")
                expect(return_set).to eql("STORED\r\n")
            end
            it "data join correctly" do  
                @mem.set("key", 10, 500, 20, "Data to be")
                @mem.append("key", 10, 500, 20, " stored")
                return_data = @mem.get(["key"])
                expect(return_data[0][4]).to eql("Data to be stored")
            end
        end
        context "given a key that doesn't exist" do
            it "return not stored" do
                return_set = @mem.append("key", 10, 500, 20, " stored")
                expect(return_set).to eql("NOT_STORED\r\n")
            end
        end
    end
    
    describe ".prepend" do
        context "given a key that exists" do
            it "correctly make the operation" do  
                @mem.set("key", 10, 500, 20, "to be stored")
                return_set = @mem.prepend("key", 10, 500, 20, "Data ")
                expect(return_set).to eql("STORED\r\n" )
            end
            it "data join correctly" do  
                @mem.set("key", 10, 500, 20, "to be stored")
                @mem.prepend("key", 10, 500, 20, "Data ")
                return_data = @mem.get(["key"])
                expect(return_data[0][4]).to eql("Data to be stored")
            end
        end
        context "given a key that doesn't exist" do
            it "return not stored" do
                return_set = @mem.prepend("key", 10, 500, 20, " stored")
                expect(return_set).to eql("NOT_STORED\r\n")
            end
        end
    end
    
    describe ".cas" do
        context "given the correct parameters" do
            it "set a value to a key that exists with a correct cas_num = 1" do  
                @mem.set("key", 10, 500, 20, "Data to be stored")
                return_set = @mem.cas("key", 10, 500, 20, 1, "New data to be stored")
                expect(return_set).to eql("STORED\r\n")
            end
            it "set a value to a key that exists with a correct cas_num > 1" do  
                @mem.set("key", 10, 500, 20, "Data to be stored")
                @mem.set("key", 10, 500, 20, "New data to be stored")
                return_set = @mem.cas("key", 10, 500, 20, 2, "New data to be stored 2")
                expect(return_set).to eql("STORED\r\n")
            end
            it "set a value to a key that exists with an incorrect cas_num" do  
                @mem.set("key", 10, 500, 20, "Data to be stored")
                return_set = @mem.cas("key", 10, 500, 20, 3, "New data to be stored")
                expect(return_set).to eql("EXISTS\r\n")
            end
            it "set a value asociated to a key that doesn't exist" do  
                return_set = @mem.cas("key", 10, 500, 20, 2, "New data to be stored")
                expect(return_set).to eql("NOT_FOUND\r\n")
            end
        end
    end
    
    describe ".delete" do
        context "given a key that exists" do
            it "correctly make the operation" do 
                @mem.set("key", 10, 500, 20, "Data to be stored")
                response = @mem.delete("key")
                expect(response).to eql(true)
            end
        end
        context "given a key that doesn't exist" do
            it "return nil" do
                response = @mem.delete("key")
                expect(response).to eql(nil)
            end
        end
    end
    
    describe ".flush_all" do
        it "correctly make the operation" do 
            response = @mem.flush_all
            expect(response).to eql("OK\r\n")
        end
    end    
end
