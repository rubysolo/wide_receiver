require 'spec_helper'
require 'wide_receiver/adapters/rabbit_adapter'
require 'wide_receiver/config'

class WideReceiver::Adapters::RabbitAdapter
  public :send_workers, :processed
end

class BrokenWorker
  def perform(*args)
    raise "kaboom"
  end
end

describe WideReceiver::Adapters::RabbitAdapter do

  let(:worker_instance) { double }
  let(:worker_class)    { double('WorkerClass', new: worker_instance) }
  let(:logger)          { WideReceiver::Config::NullLogger.new }
  let(:config)          {
                          double('Config',
                            queue_uri: URI.parse('rabbit://localhost:5672'),
                            logger:    logger,
                            options:   {} )
                        }

  it 'configures rabbit connection' do
    adapter = described_class.new(:blee, [], config: config)
    expect(adapter.send(:connection).host).to eq 'localhost'
  end

  it 'sends perform message to worker instances' do
    allow(Object).to receive(:const_get).with('SomeClass')
                                        .and_return(worker_class)
    delivery = { routing_key: :fred }
    adapter = described_class.new(:blee, ['SomeClass'])

    expect(worker_instance).to receive(:perform).with(:fred, 'breaker, breaker')
    adapter.send_workers(delivery, 'breaker, breaker')
  end

  it 'parses raw message if message_format is not configured' do
    adapter = described_class.new(:blee, [])
    expect(adapter.processed('{"hello":"json"}')).to eq('{"hello":"json"}')
  end

  it 'parses JSON message if message_format is configured' do
    allow(config).to receive(:message_format).and_return(:json)
    adapter = described_class.new(:blee, [], config: config)
    expect(adapter.processed('{"hello":"json"}')).to eq('hello' => 'json')
  end

  it 'records failed jobs in a queue' do
    WideReceiver::Config.instance.queue_url = 'rabbit://localhost:5672'
    adapter = described_class.new(:blee, ['BrokenWorker'])
    delivery = { routing_key: :fred }
    expect {
      adapter.send_workers(delivery, 'hello world')
    }.to_not raise_error
    expect(adapter.send(:error_queue).message_count).to eq 1
  end

end
