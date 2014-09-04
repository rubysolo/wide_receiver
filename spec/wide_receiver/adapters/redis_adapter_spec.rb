require 'spec_helper'
require 'wide_receiver/adapters/redis_adapter'

class WideReceiver::Adapters::RedisAdapter
  public :send_workers, :processed
end

class BrokenWorker
  def perform(*args)
    raise "kaboom"
  end
end

describe WideReceiver::Adapters::RedisAdapter do

  let(:worker_instance) { double }
  let(:worker_class)    { double('WorkerClass', new: worker_instance) }
  let(:logger)          { WideReceiver::Config::NullLogger.new }
  let(:config)          { double('Config', queue_uri: URI.parse('redis://localhost:6379/8'), logger: logger) }

  it 'configures redis connection' do
    adapter = described_class.new(:foo, [], config: config)
    redis_client = adapter.input.client
    expect(redis_client.host).to eq 'localhost'
  end

  it 'sends perform message to worker instances' do
    Object.stub(:const_get).with('SomeClass').and_return(worker_class)
    adapter = described_class.new(:foo, ['SomeClass'])

    expect(worker_instance).to receive(:perform).with(19, 'breaker, breaker')
    adapter.send_workers(19, 'breaker, breaker')
  end

  it 'parses JSON message if message_format is configured' do
    adapter = described_class.new(:foo, [])
    expect(adapter.processed('{"hello":"json"}')).to eq('{"hello":"json"}')
  end

  it 'parses JSON message if message_format is configured' do
    config.stub(:message_format).and_return(:json)
    adapter = described_class.new(:foo, [], config: config)
    expect(adapter.processed('{"hello":"json"}')).to eq('hello' => 'json')
  end

  it 'records failed jobs in a queue' do
    WideReceiver::Config.instance.queue_url = 'redis://localhost:6379/8'
    adapter = described_class.new(:foo, ['BrokenWorker'])
    expect {
      adapter.send_workers('high-priority', 'hello world')
    }.to_not raise_error
    expect(adapter.error.llen 'failures').to eq 1
  end

end
