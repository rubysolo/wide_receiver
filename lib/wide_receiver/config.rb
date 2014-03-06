require_relative 'adapters'

module WideReceiver
  class Config
    class NullUri < Struct.new(:scheme, :host, :port, :path)
    end

    attr_accessor :queue_url
    attr_writer :message_format

    def self.instance
      @instance ||= new
    end

    def self.reset!
      @instance = nil
    end

    def message_format
      @message_format || :raw
    end

    def adapter
      WideReceiver::Adapters.const_get(queue_uri.scheme.capitalize + 'Adapter')
    end

    def queue_uri
      @uri ||= URI.parse(queue_url) rescue NullUri.new('null', nil, nil, nil)
    end
  end
end
