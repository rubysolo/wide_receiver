require 'spec_helper'
require 'wide_receiver/master'

describe WideReceiver::Master do
  let(:registry) { double('Registry', channels: %w( 1 2 3 ), :'[]' => %w( NullWorker )) }
  let(:subject)  { described_class.new(registry: registry, adapter: WideReceiver::Adapters::NullAdapter) }

  it 'starts listener threads for registered channels' do
    subject.start
    expect(subject.thread_count).to eq 3
  end

end
