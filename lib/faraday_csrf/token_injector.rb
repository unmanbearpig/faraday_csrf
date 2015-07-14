require 'faraday_csrf/token'

module Faraday
  class CSRF
    class TokenInjector
      class MissingToken < Exception
      end

      DEFAULT_IGNORE_METHODS = [:get, :head]

      attr_reader :ignore_methods

      def initialize(ignore_methods: DEFAULT_IGNORE_METHODS)
        @ignore_methods  = ignore_methods
      end

      def inject(token, into:)
        return unless should_inject?(into)

        raise MissingToken unless token

        inject!(token, env: into)
      end

      def inject!(token, env:)
        env.body.merge! token.to_h
        token.expire!
      end

      def should_inject? env
        return false if ignore_methods.include?(env.method)
        return false unless env.body.respond_to? :merge!
        true
      end
    end
  end
end
