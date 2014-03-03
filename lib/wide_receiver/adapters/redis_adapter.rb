begin
  require 'redis'
rescue LoadError => e
end

module WideReceiver
  module Adapters
    class RedisAdapter
      attr_reader :config

      def initialize(channel, workers, config: Config.instance)
        @pattern = channel
        @worker_classes = workers.map { |w| Object.const_get(w) }
        @config = config
        @redis = Redis.new(redis_config(config.queue_uri))
      end

      def work
        @redis.psubscribe(@pattern) do |on|
          on.pmessage do |pattern, channel, message|
            send_workers channel, processed(message)
          end
        end
      end

      private

      def processed(message)
        case config.message_format
        when :json
          JSON.parse(message)
        else
          message
        end
      end

      def send_workers(channel, message)
        @worker_classes.each do |worker_class|
          worker_class.new.perform(channel, message)
        end
      end

      def redis_config(uri)
        {
          host: uri.host,
          port: uri.port,
          db:   uri.path.to_s.scan(/\d+/).flatten.first
        }.reject { |k,v| v.nil? }
      end
    end
  end
end
