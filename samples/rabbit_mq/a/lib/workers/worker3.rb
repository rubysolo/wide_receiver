class Worker3
  extend WideReceiver::Worker
  listen 'bumble.bee.tuna'

  def perform( channel, message )
    puts "[RX] (#{self.class.name}) Channel `#{channel}. GOT #{message.inspect}"
  end
end
