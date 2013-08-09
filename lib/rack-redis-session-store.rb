require 'rack/session/abstract/id'
require 'action_dispatch/middleware/session/abstract_store'
require 'redis'
require 'connection_pool'

module ActionDispatch
  module Session
    class RedisStore < Rack::Session::Abstract::ID
      def initialize(app, options = {})
        @redis = ConnectionPool.new(:size => options[:max_connections], :timeout => 5) {
          Redis.new(:host => "#{options[:host]}", :port => options[:port], db: options[:db])
        }
        options[:expire_after] ||= 1.day.to_i
        super
      end

      def generate_sid
        @redis.with do |redis|
          loop do
            sid = super
            break sid unless redis.get(sid)
          end
        end
      end

      def get_session(env, sid)
        @redis.with do |redis|
          unless sid and session = MultiJson.load(redis.get(sid) || '{}')
            sid, session = generate_sid, {}
          end
          [sid, session]
        end
      end

      def set_session(env, session_id, new_session, options)
        expiry = options[:expire_after]
        expiry = expiry.nil? ? 0 : expiry + 1

        @redis.with do |redis|
          json = MultiJson.dump(new_session)
          redis.setex session_id, expiry,json
          session_id
        end
      end

      def destroy_session(env, session_id, options)
        @redis.with do |redis|
          redis.del(session_id)
          generate_sid unless options[:drop]
        end
      end
    end
  end
end