require_relative 'adapters'

module WideReceiver
  class Config
    class NullUri < Struct.new(:scheme, :host, :port, :path)
    end

    class NullLogger
      def fatal; end
      def error; end
      def warn;  end
      def info;  end
      def debug; end
    end

    attr_accessor :queue_url
    attr_writer :message_format, :logger

    def self.configure
      yield instance
    end

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

    def logger
      @logger ||= NullLogger.new
    end
  end
end
