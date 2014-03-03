require_relative 'registry'

module WideReceiver
  module Worker
    def listen(*channels, registry: Registry.instance)
      @channels = channels
      registry.register(self.to_s, channels)
    end

    def channels
      @channels
    end
  end
end
