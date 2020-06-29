require_relative 'memcached_item'
require 'concurrent'


module MemcachedTest
    class Memcached
        def initialize
            @cache = Concurrent::Hash.new
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
                item = Memcached_item.new(flags, exptime, bytes, @cache[key].cas.to_i + 1, data[0, bytes.to_i])
                @cache[key] = item
                return "STORED\r\n" 
            else
                item = Memcached_item.new(flags, exptime, bytes, 1, data[0, bytes.to_i])
                @cache[key] = item
                return "STORED\r\n"  
            end
        end

        def add(key, flags, exptime, bytes, data)
            if @cache.key?(key)
                return "NOT_STORED\r\n"
            else
                item = Memcached_item.new(flags, exptime, bytes, 1, data[0, bytes.to_i])
                @cache[key] = item
                return "STORED\r\n" 
            end
        end

        def replace(key, flags, exptime, bytes, data)
            if @cache.key?(key)
                item = Memcached_item.new(flags, exptime, bytes, @cache[key].cas + 1, data[0, bytes.to_i])
                @cache[key] = item
                return "STORED\r\n"
            else
                return "NOT_STORED\r\n"
            end
        end

        def append(key, bytes, data)
            if @cache.key?(key)        
                item_old = @cache[key]
                item_new = Memcached_item.new(item_old.flags, item_old.exptime, item_old.bytes.to_i + bytes.to_i, @cache[key].cas + 1, item_old.data + data[0, bytes.to_i])
                @cache[key] = item_new
                return "STORED\r\n"
            else
                return "NOT_STORED\r\n"
            end
        end

        def prepend(key, bytes, data)
            if @cache.key?(key)
                item_old = @cache[key]
                item_new = Memcached_item.new(item_old.flags, item_old.exptime, item_old.bytes.to_i + bytes.to_i, @cache[key].cas + 1, data[0, bytes.to_i] + item_old.data)
                @cache[key] = item_new
                return "STORED\r\n"
            else
                return "NOT_STORED\r\n"
            end
        end

        def cas(key, flags, exptime, bytes, cas, data)
            if @cache.key?(key) 
                if @cache[key].cas == cas.to_i
                    item = Memcached_item.new(flags, exptime, bytes, cas.to_i + 1, data[0, bytes.to_i])
                    @cache[key] = item
                    return "STORED\r\n"
                else
                    return "EXISTS\r\n"
                end
            else
                return "NOT_FOUND\r\n"
            end
        end

        def delete(key)
            if @cache.key?(key)
                @cache.delete(key)
                return true
            else
                return nil
            end        
        end

        def flush_all()
            @cache.each_key do |key|
                if Time.now() > @cache[key].exptime
                    self.delete(key)
                end
            end
            return "OK\r\n"
        end
    end
end