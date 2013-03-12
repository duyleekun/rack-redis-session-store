require 'rack/session/abstract/id'
require 'action_dispatch/middleware/session/abstract_store'
require 'redis'
require 'connection_pool'

module ActionDispatch
  module Session
    class RedisStore < Rack::Session::Abstract::ID
      def initialize(app, options = {})
        @redis = ConnectionPool::Wrapper.new(:size => options[:max_connections], :timeout => 5) {
          Redis.new(:host => "#{options[:host]}", :port => options[:port], db: options[:db])
        }
        super
      end

      def generate_sid
        loop do
          sid = super
          break sid unless @redis.get(sid)
        end
      end

      def get_session(env, sid)
        unless sid and session = @redis.get(sid)
          sid, session = generate_sid, {}
          unless /^OK/ =~ @redis.set(sid, session.to_json)
            raise "Session collision on '#{sid.inspect}'"
          end
        else
          session = JSON.parse(session)
        end
        [sid, session]
      end

      def set_session(env, session_id, new_session, options)
        @redis.set session_id, new_session.to_json
        session_id
      end

      def destroy_session(env, session_id, options)
        @redis.del(session_id)
        generate_sid unless options[:drop]
      end
    end
  end
end