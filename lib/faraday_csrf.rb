require "faraday_csrf/version"
require 'faraday_csrf/token_handler'

module Faraday
  class CSRF
    attr_reader :app

    def initialize(app, options = {})
      @app = app

      fetch_url = options[:fetch_token_from_url]
      if fetch_url
        fetcher = TokenFetcher.new app: self, url: fetch_url
      else
        fetcher = Proc.new {}
      end

      @handler = options.fetch(:handler) do
        TokenHandler.new extractor: DefaultExtractor,
                         injector: TokenInjector.new,
                         fetcher: fetcher
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
