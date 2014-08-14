begin
  require 'bunny'
rescue LoadError => e
end

module WideReceiver
  module Adapters
    class RabbitAdapter
      attr_reader :config, :logger, :pattern, :settings

      def initialize(pattern, workers, config: Config.instance)
        @pattern  = pattern
        @workers  = workers.map { |w| Object.const_get(w) }
        @config   = config
        @logger   = config.logger
        @settings = sync_options( config.options )

        init_rabbit
        init_error_queue
        logger.debug { "started rabbitMQ adapter" }
      end

      def work
        queue.bind(exchange, routing_key:pattern)
             .subscribe(settings[:subscribe]) { |delivery, meta, payload|
          logger.info  { "received message '#{ delivery[:routing_key] }'" }
          logger.debug { payload }

          send_workers delivery, processed(payload)
        }
      end

      private

      def init_error_queue
        @error_channel = connection.create_channel
        @error_queue   = @error_channel.queue("wr_errors")
      end

      def queue_error( error )
        @error_channel.default_exchange
                      .publish(error, :routing_key => @error_queue.name)
      end

      def error_queue() @error_queue end
      def queue()       @queue       end
      def exchange()    @exchange    end
      def channel()     @channel     end

      def sync_options( options )
        opts = {
          exchange: {
            topic: :default
          },
          queue: {
            name:        "",
            durable:     false,
            auto_delete: false,
            exclusive:   false
          },
          subscribe: {
            block: true,
            ack:   false
          }
        }

        if options
          opts[:exchange].merge!( options[:exchange] )   if options[:exchange]
          opts[:queue].merge!( options[:queue] )         if options[:queue]
          opts[:subscribe].merge!( options[:subscribe] ) if options[:subscribe]
        end
        auto_delete = opts[:queue].delete(:auto_delete)
        opts[:queue]['auto-delete'.to_sym] = auto_delete
        opts
      end

      def init_rabbit
        connection.start

        @channel  = connection.create_channel
        @exchange = channel.topic(settings[:exchange][:topic],
                                  settings[:exchange])
        @queue    = channel.queue(settings[:queue][:name], settings[:queue])
      end

      def processed(message)
        case config.message_format
        when :json
          MultiJson.load(message)
        else
          message
        end
      end

      def send_workers(delivery, message)
        @workers.each do |worker_class|
          begin
            logger.debug { "  sending message to '#{ worker_class }'" }
            worker_class.new.perform(delivery[:routing_key], message)
          rescue => e
            logger.error { "  *** ERROR [#{ worker_class }]: #{ e.message }" }

            queue_error MultiJson.dump(
              worker:     worker_class.to_s,
              channel:    delivery[:routing_key],
              message:    message,
              exception:  e.message
            )
          end
        end
        channel.ack(delivery.delivery_tag) if settings[:exchange][:ack] == true
      end

      def connection
        @connection ||= Bunny.new(rabbit_config(config.queue_uri))
      end

      def rabbit_config(uri)
        config = {
          host: uri.host,
          port: uri.port
        }

        begin
          user_info = uri.select(:user_info)
          tokens = user_info.split(/:/)
          if tokens.size == 2
            config.merge!( {username:tokens.first, password:tokens.last} )
          end
        rescue
          ; # No deal if no auth
        end
        config.reject { |k,v| v.nil? }
      end
    end
  end
end
