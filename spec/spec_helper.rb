require 'pry'

RSpec.configure do |config|
  config.order = "random"

  config.after :each do
    if WideReceiver::Config.instance.adapter.to_s =~ /RedisAdapter/
      redis = WideReceiver::Config.instance.adapter.new(:channel, []).redis
      redis.flushdb
    end

    WideReceiver::Config.reset!
  end
end
