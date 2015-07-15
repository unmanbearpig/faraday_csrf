require "faraday_csrf/version"
require "faraday_csrf/token_fetcher"
require "faraday_csrf/token_injector"
require 'faraday_csrf/token_extractors/default_extractor'

module Faraday
  class CSRF
    attr_reader :app, :token, :extractor, :injector, :fetcher

    def initialize(app, options = {})
      @app = app
      @extractor = options.fetch(:extractor) { DefaultExtractor }
      @injector = options.fetch(:injector) { TokenInjector.new }

      fetch_url = options[:fetch_token_from_url]
      if fetch_url
        @fetcher = TokenFetcher.new fetch_url
      else
        @fetcher = Proc.new {}
      end
    end

    def call request_env
      handle_request request_env

      app.call(request_env).on_complete do |response_env|
        handle_response response_env
      end
    end

    def handle_request request_env
      injector.inject(token, into: request_env)
    rescue TokenInjector::MissingToken
      fetcher.call self, request_env
      retry
    end

    def handle_response response_env
      response_env[:csrf_token] =
        extract_token_from response_env.body
    end

    def extract_token_from(response_body)
      @token = extractor.extract_from(response_body)
    rescue Token::NotFound
      nil
    end
  end
end

if Faraday::Middleware.respond_to? :register_middleware
  Faraday::Middleware.register_middleware :csrf => Faraday::CSRF
end
