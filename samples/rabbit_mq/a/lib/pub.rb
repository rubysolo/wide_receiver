require 'json'

class Pub
  attr_reader :exchange

  def initialize( exchange_name )
    rabbit.start

    channel   = rabbit.create_channel
    @exchange = channel.topic(exchange_name)
  end

  def send( key, message )
    puts "[TX] #{key} -- #{message}"
    exchange.publish( message.to_json, routing_key:key )
    rabbit.close
  end

  private

  def rabbit
    @rabbit ||= Bunny.new
  end
end
