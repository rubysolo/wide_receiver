module WideReceiver
  module Adapters
    class NullAdapter
      def initialize(channel, workers)
      end

      def work
        sleep 0.001 # pause so the test can count threads
      end
    end
  end
end
