module WideReceiver
  module Adapters
  end
end

Dir[File.dirname(__FILE__) + '/adapters/*.rb'].each do |adapter|
  require_relative "adapters/#{ File.basename(adapter, '.rb') }"
end
