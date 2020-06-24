require 'ruby-enum'

module MemcachedTest
    class Commands_format
        include Ruby::Enum

        define :get, /^get (?<keys>(\w|[ ])+)/
        define :gets, /^gets (?<keys>(\w|[ ])+)/
    
        define :set, /^set (?<key>\w+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
        define :add, /^add (?<key>\w+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
        define :replace, /^replace (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
    
        define :append, /^append (?<key>\w+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
        define :prepend, /^prepend (?<key>\w+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/
    
        define :cas, /^cas (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+) (?<cas_id>\d+)(?<noreply> noreply)? (?<data>(\w|[ ])+)/

        define :flush_all, /^flush_all(?<noreply> noreply)?/
    end
end