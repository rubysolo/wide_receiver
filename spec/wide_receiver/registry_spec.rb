require 'spec_helper'
require 'wide_receiver/registry'
require 'wide_receiver/worker'

class ActivityWorker
  extend WideReceiver::Worker
  listen "*.reported.activity"
end

describe WideReceiver::Registry do

  it 'connects workers with channels' do
    registry = described_class.instance
    expect(registry['*.reported.activity']).to eq %w( ActivityWorker )
  end

end
