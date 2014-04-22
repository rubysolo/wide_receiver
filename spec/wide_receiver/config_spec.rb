require 'spec_helper'
require 'wide_receiver/config'

describe WideReceiver::Config do

  it 'returns adapter class for connection' do
    config = described_class.new
    config.queue_url = "redis://localhost:6379/5"

    expect(config.adapter.to_s).to eq 'WideReceiver::Adapters::RedisAdapter'
  end

  it 'returns null object when queue url not specified' do
    config = described_class.new
    expect(config.queue_uri.scheme).to eq 'null'
    expect(config.queue_uri.host).to be_nil
  end

  it 'allows setting a logger' do
    logger = double

    config = described_class.new
    config.logger = logger
    expect(logger).to receive(:debug)

    logger.debug "message"
  end

  it 'provides a null logger' do
    config = described_class.new
    expect { config.logger.debug }.to_not raise_error
  end
end
