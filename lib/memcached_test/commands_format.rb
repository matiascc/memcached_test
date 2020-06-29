require 'ruby-enum'

module MemcachedTest
    class Commands_format
        include Ruby::Enum

        define :get, /^(?<command>get) (?<keys>(\w|[ ])+)/
        define :gets, /^(?<command>gets) (?<keys>(\w|[ ])+)/
    
        define :set, /^(?<command>set) (?<key>\w+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
        define :add, /^(?<command>add) (?<key>\w+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
        define :replace, /^(?<command>replace) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
    
        define :append, /^(?<command>append) (?<key>\w+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
        define :prepend, /^(?<command>prepend) (?<key>\w+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
    
        define :cas, /^(?<command>cas) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+) (?<cas>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/

        define :flush_all, /^flush_all(?<noreply> noreply)?/
    end
end