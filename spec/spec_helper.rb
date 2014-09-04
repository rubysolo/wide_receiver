require 'pry'
require 'simplecov'

SimpleCov.start if ENV['COV']

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

    if WideReceiver::Config.instance.adapter.to_s =~ /AmqpAdapter/
      adapter = WideReceiver::Config.instance.adapter.new(:channel, [])
      adapter.queue.delete
      adapter.error_queue.delete
    end

    WideReceiver::Config.reset!
  end
end
