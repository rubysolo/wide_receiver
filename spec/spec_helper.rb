require 'pry'

RSpec.configure do |config|
  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  
  config.after :each do
    if WideReceiver::Config.instance.adapter.to_s =~ /RedisAdapter/
      redis = WideReceiver::Config.instance.adapter.new(:channel, []).error
      redis.flushdb
    end

    WideReceiver::Config.reset!
  end
end
