require "faraday_csrf/version"
require 'faraday_csrf/creates_token_handler'

module Faraday
  class CSRF
    attr_reader :app

    def initialize(app, options = {})
      @app = app
      @handler = options.fetch(:token_handler) do
        CreatesTokenHandler.create(options.merge(app: self))
      end
    end

    def call request_env
      @handler.handle_request request_env

      app.call(request_env).on_complete do |response_env|
        @handler.handle_response response_env
      end
    end
  end
end

if Faraday::Middleware.respond_to? :register_middleware
  Faraday::Middleware.register_middleware :csrf => Faraday::CSRF
end
