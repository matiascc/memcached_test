require_relative 'memcached_item'

class Memcached
    
    def initialize
        @cache = Hash.new
    end

    def get(keys)
        result = []
        
        for key in keys do
            item = @cache[key]
            unless item.nil?
                item_array = [key, item.flags, item.exptime, item.bytes, item.data]
                result.append(item_array)
            end
        end
        return result
    end

    def gets(keys)
        result = []
        
        for key in keys do
            item = @cache[key]
            unless item.nil?
                item_array = [key, item.flags, item.exptime, item.bytes, item.cas, item.data]
                result.append(item_array)
            end
        end
        return result
    end

    def set(key, flags, exptime, bytes, data)
        if @cache.key?(key)
            item = Memcached_item.new(flags, exptime, bytes, @cache[key].cas + 1, data)
            @cache[key] = item
            return "STORED\r\n" 
        else
            item = Memcached_item.new(flags, exptime, bytes, 1, data)
            @cache[key] = item
            return "STORED\r\n"  
        end
    end

    def add(key, flags, exptime, bytes, data)
        if @cache.key?(key)
            return "NOT_STORED\r\n"
        else
            item = Memcached_item.new(flags, exptime, bytes, 1, data)
            @cache[key] = item
            return "STORED\r\n" 
        end
    end

    def replace(key, flags, exptime, bytes, data)
        if @cache.key?(key)
            item = Memcached_item.new(flags, exptime, bytes, @cache[key].cas + 1, data)
            @cache[key] = item
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def append(key, flags, exptime, bytes, data)
        if @cache.key?(key)        
            item_old = @cache[key]
            item_new = Memcached_item.new(flags, exptime, bytes, @cache[key].cas + 1, item_old.data + data)
            @cache[key] = item_new
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def prepend(key, flags, exptime, bytes, data)
        if @cache.key?(key)
            item_old = @cache[key]
            item_new = Memcached_item.new(flags, exptime, bytes, @cache[key].cas + 1, data + item_old.data)
            @cache[key] = item_new
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def cas(key, flags, exptime, bytes, cas, data)
        if @cache.key?(key) 
            if @cache[key].cas == cas
                item = Memcached_item.new(flags, exptime, bytes, cas, data)
                @cache[key] = item
                return "STORED\r\n"
            else
                return "EXISTS\r\n"
            end
        else
            return "NOT_FOUND\r\n"
        end
    end
end
