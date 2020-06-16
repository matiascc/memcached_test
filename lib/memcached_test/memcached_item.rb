class Memcached_item
    
    attr_accessor :flags
    attr_accessor :exptime
    attr_accessor :bytes
    attr_accessor :data

    def initialize(flags, exptime, bytes, data)
        @flags = flags
        @exptime = exptime
        @bytes = bytes
        @data = data
    end
end