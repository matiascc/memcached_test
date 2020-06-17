require_relative 'memcached_item'

class Memcached
    
    def initialize
        @cache = Hash.new
    end

    def get(key)
        if @cache.key?(key)
            item = @cache[key]
            return [key, item.flags, item.exptime, item.bytes, item.data]
        else
            return nil
        end
    end

    def multiple_get(keys)
        result = []
        
        for key in keys do
            item = self.get(key)
            result.append(item) unless item.nil?
        end

        return result
    end

    def set(key, flags, exptime, bytes, data)
        item = Memcached_item.new(flags, exptime, bytes, data)
        @cache[key] = item
        return "STORED\r\n"        
    end

    def add(key, flags, exptime, bytes, data)
        if @cache.key?(key)
            return "NOT_STORED\r\n"
        else
            item = Memcached_item.new(flags, exptime, bytes, data)
            @cache[key] = item
            return "STORED\r\n" 
        end
    end

    def replace(key, flags, exptime, bytes, data)
        if @cache.key?(key)
            item = Memcached_item.new(flags, exptime, bytes, data)
            @cache[key] = item
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def append(key, flags, exptime, bytes, data)
        item_old = @cache[key]
        item_new = Memcached_item.new(flags, exptime, bytes, item_old.data + data)
        @cache[key] = item_new
        return "STORED\r\n"
    end

    def prepend(key, flags, exptime, bytes, data)
        item_old = @cache[key]
        item_new = Memcached_item.new(flags, exptime, bytes, data + item_old.data)
        @cache[key] = item_new
        return "STORED\r\n"
    end

    def cas()

    end    
end
