# Wide Receiver

Wide Receiver is a work queue system in which the worker classes decide which
messages to process.

## Installation

Add this line to your application's Gemfile:

    gem 'wide_receiver'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wide_receiver

## Usage

Configure Wide Receiver to connect to your queuing system (currently only
supports Redis pubsub):

```ruby
WideReceiver::Config.instance.queue_url = 'redis://localhost/6379/5'
```

Create a worker class that extends `WideReceiver::Worker` and specifies which channel
patterns it wants to process:

```ruby
class Rice
  extend WideReceiver::Worker
  listen 'montana.pass.*'

  def perform(channel, message)
    # do something with message
  end
end
```

Start the master process:

```ruby
WideReceiver::Master.new.start
```

This will start one thread per unique channel pattern.  When a message is
received on a matching channel, each worker class that expressed interest in
that pattern will be instantiated, and the instance will receive the message.

## TODO

- add support for RabbitMQ
- add proper command line runner

## Contributing

1. Fork it ( http://github.com/rubysolo/wide_receiver/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
