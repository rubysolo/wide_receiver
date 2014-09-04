require 'wide_receiver'

config = WideReceiver::Config.instance

config.queue_url      = "amqp://localhost:5672"
config.message_format = :json
config.options        = {
  exchange: {
    topic: 'a'
  },
  queue: {
    auto_delete: true
  }
}

Dir[File.join(File.dirname(__FILE__), "../lib/workers/*.rb")].each do |worker|
  require worker
end
