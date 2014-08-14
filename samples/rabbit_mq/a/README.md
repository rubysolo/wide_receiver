# RabbitMQ Specimen# A

Publish events to 3 workers listening on different routing keys.

## Running the example

1. Install and start rabbitMQ
2. Start WideReceiver
```
$ bundle exec wide_receiver config/wide_receiver.rb
```
3. Publish some events
```
./bin/pub bumble.bee.tuna Hello
```
