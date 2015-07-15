module Faraday
  class CSRF
    class TokenFetcher
      def initialize(app:, url:)
        @app = app
        @url = url
      end

      def call request_env
        new_env = request_env.dup
        new_env.url = request_env.url.dup
        new_env.url.path = @url

        new_env.method = :get

        @app.call(new_env)
      end
    end
  end
end
