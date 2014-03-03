require_relative 'adapters'

module WideReceiver
  class Config
    class NullUri < Struct.new(:scheme, :host, :port, :path)
    end

    attr_accessor :queue_url

    def self.instance
      @instance ||= new
    end

    def adapter
      WideReceiver::Adapters.const_get(queue_uri.scheme.capitalize + 'Adapter')
    end

    def queue_uri
      @uri ||= URI.parse(queue_url) rescue NullUri.new('null', nil, nil, nil)
    end
  end
end
