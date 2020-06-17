require 'memcached_test/memcached'

describe ".set" do
    context "given the correct parameters" do
        it "set a value asociated to a key" do  
            mem = Memcached.new
            return_set = mem.set("key", 10, 500, 20, "Data to be stored")
            expect(return_set).to eql("STORED\r\n" )
        end
    end
end

describe ".get" do
    context "given a key that exist" do
        it "get a value asociated to a key" do  
            mem = Memcached.new
            mem.set("key", 10, 500, 20, "Data to be stored")

            return_get = mem.get("key")
            expect(return_get).to eql(["key", 10, 500, 20, "Data to be stored"])
        end
    end
end

describe ".multiple_get" do
    context "given multiple keys that exists" do
        it "get a values asociated to 2 keys" do  
            mem = Memcached.new
            mem.set("key", 10, 500, 10, "Data to be stored")
            mem.set("key2", 20, 500, 10, "Data to be stored2")

            return_gets = mem.multiple_get(["key", "key2"])
            expect(return_gets).to eql([["key", 10, 500, 10, "Data to be stored"],["key2", 20, 500, 10, "Data to be stored2"]])
        end
    end
end

describe ".add" do
    context "given the correct parameters" do
        it "set a value asociated to a key that don't exist" do  
            mem = Memcached.new
            return_set = mem.add("key", 10, 500, 20, "Data to be stored")
            expect(return_set).to eql("STORED\r\n")
        end
        it "set a value asociated to a key that exist" do  
            mem = Memcached.new
            mem.add("key", 10, 500, 20, "Data to be stored")
            return_set = mem.add("key", 10, 500, 20, "Data to be stored")
            expect(return_set).to eql("NOT_STORED\r\n")
        end
    end
end

describe ".replace" do
    context "given the correct parameters" do
        it "set a value asociated to a key that don't exist" do  
            mem = Memcached.new
            mem.replace("key", 10, 500, 20, "Data to be stored")
            return_set = mem.replace("key", 10, 500, 20, "New data to be stored")
            expect(return_set).to eql("STORED\r\n")
        end
        it "set a value asociated to a key that exist" do  
            mem = Memcached.new
            return_set = mem.replace("key", 10, 500, 20, "New data to be stored")
            expect(return_set).to eql("NOT_STORED\r\n")
        end
    end
end

describe ".append" do
    context "given the correct parameters" do
        it "correctly make the operation" do  
            mem = Memcached.new
            mem.set("key", 10, 500, 20, "Data to be")
            return_set = mem.append("key", 10, 500, 20, " stored")
            expect(return_set).to eql("STORED\r\n" )
        end
        it "data join correctly" do  
            mem = Memcached.new
            mem.set("key", 10, 500, 20, "Data to be")
            mem.append("key", 10, 500, 20, " stored")
            return_data = mem.get(key)
            expect(return_data[4]).to eql("Data to be stored")
        end
    end
end

describe ".prepend" do
    context "given the correct parameters" do
        it "correctly make the operation" do  
            mem = Memcached.new
            mem.set("key", 10, 500, 20, "to be stored")
            return_set = mem.prepend("key", 10, 500, 20, "Data ")
            expect(return_set).to eql("STORED\r\n" )
        end
        it "data join correctly" do  
            mem = Memcached.new
            mem.set("key", 10, 500, 20, "to be stored")
            mem.prepend("key", 10, 500, 20, "Data ")
            return_data = mem.get(key)
            expect(return_data[4]).to eql("Data to be stored")
        end
    end
end