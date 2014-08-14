class Worker1
  extend WideReceiver::Worker
  listen 'bumble.bee.*'

  def perform( channel, message )
    puts "[RX] (#{self.class.name}) Channel `#{channel}. GOT #{message.inspect}"
  end
end
