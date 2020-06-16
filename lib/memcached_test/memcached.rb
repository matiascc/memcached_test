require './memcached_item'

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
    end

    def add()

    end

    def replace()

    end

    def append()

    end

    def prepend()

    end

    def cas()

    end    
end
