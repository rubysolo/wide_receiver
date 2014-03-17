require 'thread'
require_relative 'registry'
require_relative 'config'

Thread.abort_on_exception = true

module WideReceiver
  class Master
    attr_reader :registry, :adapter

    def initialize(registry: Registry.instance, adapter: Config.instance.adapter)
      @adapter  = adapter
      @registry = registry
      @threads  = []
    end

    def start
      registry.channels.each do |channel|
        workers = registry[channel]

        @threads << Thread.new do
          adapter.new(channel, workers).work
        end
      end

      @threads.each { |t| t.join }
    end

    def thread_count
      @threads.size
    end
  end
end
