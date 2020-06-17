class Memcached_item
    
    attr_accessor :flags
    attr_accessor :exptime
    attr_accessor :bytes
    attr_accessor :cas
    attr_accessor :data

    def initialize(flags, exptime, bytes, cas, data)
        @flags = flags
        @exptime = exptime
        @bytes = bytes
        @cas = cas
        @data = data
    end
end