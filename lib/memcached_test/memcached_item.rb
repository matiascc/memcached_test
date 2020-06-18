class Memcached_item
    
    attr_accessor :flags
    attr_accessor :exptime
    attr_accessor :bytes
    attr_accessor :cas
    attr_accessor :data

    def initialize(flags, exptime, bytes, cas, data)
        @flags = flags
        @exptime = set_exptime(exptime)
        @bytes = bytes
        @cas = cas
        @data = data
    end
    
    def set_exptime(exptime)
        if exptime.to_i == 0
            return nil
        elsif exptime.to_i < 2592000
            return Time.now().getutc() + exptime.to_i
        else
            return Time.at(exptime.to_i)
        end
    end
end