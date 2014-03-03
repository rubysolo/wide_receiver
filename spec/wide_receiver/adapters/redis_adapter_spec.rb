require 'spec_helper'
require 'wide_receiver/adapters/redis_adapter'

class WideReceiver::Adapters::RedisAdapter
  attr_reader :redis
  public :send_workers
end

describe WideReceiver::Adapters::RedisAdapter do

  let(:worker_instance) { double }
  let(:worker_class)    { double('WorkerClass', new: worker_instance) }

  it 'configures redis connection' do
    adapter = described_class.new(:foo, [], queue_uri: URI.parse('redis://localhost:6379/8'))
    redis_client = adapter.redis.client
    expect(redis_client.host).to eq 'localhost'
  end

  it 'sends perform message to worker instances' do
    Object.stub(:const_get).with('SomeClass').and_return(worker_class)
    adapter = described_class.new(:foo, ['SomeClass'])

    expect(worker_instance).to receive(:perform).with(19, 'breaker, breaker')
    adapter.send_workers(19, 'breaker, breaker')
  end

end
