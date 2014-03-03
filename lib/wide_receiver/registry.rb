require 'thread'

module WideReceiver
  class Registry
    def self.instance
      @instance ||= new
    end

    def initialize
      @registry = Hash.new { |h,k| h[k] = [] }
      @lock = Mutex.new
    end

    def register(worker_class, channels)
      @lock.synchronize do
        channels.each do |channel|
          @registry[channel] << worker_class
        end
      end
    end

    def [](channel)
      @lock.synchronize { @registry[channel] }
    end

    def channels
      @lock.synchronize { @registry.keys }
    end
  end
end
