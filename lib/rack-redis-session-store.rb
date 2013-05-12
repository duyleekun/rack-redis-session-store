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
        session = {}
        if sid!='null'
          @redis.with do |redis|
            options = env['rack.session.options']
            session_string = redis.get(sid)
            if session_string
              session = JSON.parse(session_string)
            end
          end
        else
          sid = generate_sid
        end
        [sid, session]
      end

      def set_session(env, session_id, new_session, options)
        if (!new_session.empty?)
          @redis.with do |redis|
            json = Jbuilder.encode do |json|
              json.(new_session, *new_session.keys)
            end
            redis.setex session_id, options[:expire_after],json
          end
        end
        #For some reason, rack doesn't set new session_id to options[:id]
        options[:id] = session_id
      end

      def destroy_session(env, session_id, options)
        puts('Destroy session')
        @redis.with do |redis|
          redis.del(session_id)
        end
        generate_sid unless options[:drop]
      end
    end
  end
end