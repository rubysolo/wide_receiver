begin
  require 'redis'
  require 'redis-namespace'
rescue LoadError => e
end

module WideReceiver
  module Adapters
    class RedisAdapter
      attr_reader :config, :redis

      def initialize(channel, workers, config: Config.instance)
        @pattern = channel
        @workers = workers.map { |w| Object.const_get(w) }
        @config  = config
        @redis   = Redis::Namespace.new(:wide_receiver, redis: Redis.new(redis_config(config.queue_uri)))
      end

      def work
        @redis.redis.psubscribe(@pattern) do |on|
          on.pmessage do |pattern, channel, message|
            send_workers channel, processed(message)
          end
        end
      end

      private

      def processed(message)
        case config.message_format
        when :json
          MultiJson.load(message)
        else
          message
        end
      end

      def send_workers(channel, message)
        @workers.each do |worker_class|
          begin
            worker_class.new.perform(channel, message)
          rescue => e
            @redis.lpush 'failures', MultiJson.dump(
              worker:     worker_class.to_s,
              channel:    channel,
              message:    message,
              exception:  e.message
            )
          end
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
