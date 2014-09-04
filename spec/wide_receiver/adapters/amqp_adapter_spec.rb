require 'spec_helper'
require 'wide_receiver/adapters/amqp_adapter'
require 'wide_receiver/config'

class WideReceiver::Adapters::AmqpAdapter
  public :send_workers, :processed
end

class BrokenWorker
  def perform(*args)
    raise 'kaboom'
  end
end

describe WideReceiver::Adapters::AmqpAdapter do
  let(:amqp_uri)        { 'amqp://localhost:5672' }
  let(:worker_instance) { double }
  let(:worker_class)    { double('WorkerClass', new: worker_instance) }
  let(:logger)          { WideReceiver::Config::NullLogger.new }
  let(:config)          {
                          double('Config',
                            queue_uri: URI.parse(amqp_uri),
                            logger:    logger,
                            options: {
                              queue: {
                                auto_delete: true
                              }
                            }
                          )
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
    WideReceiver::Config.instance.queue_url = amqp_uri
    adapter = described_class.new(:blee, ['BrokenWorker'])
    adapter.error_queue.purge

    delivery = { routing_key: :fred }
    expect {
      adapter.send_workers(delivery, 'hello world')
    }.to_not raise_error
    sleep(0.2)
    expect(adapter.error_queue.message_count).to eq 1
  end

  context '#sync_options' do
    it 'merges user options correctly' do
      c = WideReceiver::Config.instance
      c.queue_url      = amqp_uri
      c.message_format = :json
      c.options        = {
        exchange: {
          topic: 'a'
        },
        queue: {
          name:        'fred',
          auto_delete: true
        }
      }
      adapter = described_class.new(:blee, [], config:c)
      settings = adapter.settings

      expect(settings[:exchange][:topic]).to      eq 'a'
      expect(settings[:queue][:name]).to          eq 'fred'
      expect(settings[:queue][:'auto-delete']).to eq true
    end
  end
end
