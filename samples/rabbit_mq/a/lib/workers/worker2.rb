class Worker2
  extend WideReceiver::Worker
  listen 'bumble.#'

  def perform(channel, message)
    puts "[RX] (#{self.class.name}) Channel `#{channel}. GOT #{message.inspect}"
  end
end
