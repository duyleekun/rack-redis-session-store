# Rack::Redis::Session::Store

Multi-threaded Redis store for rack ID-based session (with maximum Redis connection for connection pool)

## Installation

Add this line to your application's Gemfile:

    gem 'rack-redis-session-store'

And then execute:

    $ bundle install

## Usage

For rails, replace this in your session_store initializer
```ruby
IMuaSam::Application.config.session_store :redis_store, host: "redis.host", port: 1234, db: '1234', key: 'session_id', max_connections: 16
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
