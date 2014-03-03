require 'spec_helper'
require 'wide_receiver/worker'

class TestWorker
  extend WideReceiver::Worker
  listen "*"
end

describe WideReceiver::Worker do

  it 'listens to named channels' do
    expect(TestWorker.channels).to eq ['*']
  end

end
