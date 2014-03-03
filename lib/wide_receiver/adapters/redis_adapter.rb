begin
  require 'redis'
rescue LoadError => e
end

module WideReceiver
  module Adapters
    class RedisAdapter
      def initialize(channel, workers, queue_uri: Config.instance.queue_uri)
        @pattern = channel
        @worker_classes = workers.map { |w| Object.const_get(w) }
        @redis = Redis.new(config(queue_uri))
      end

      def work
        @redis.psubscribe(@pattern) do |on|
          on.pmessage do |pattern, channel, message|
            send_workers channel, message
          end
        end
      end

      private

      def send_workers(channel, message)
        @worker_classes.each do |worker_class|
          worker_class.new.perform(channel, message)
        end
      end

      def config(uri)
        {
          host: uri.host,
          port: uri.port,
          db:   uri.path.to_s.scan(/\d+/).flatten.first
        }.reject { |k,v| v.nil? }
      end
    end
  end
end
