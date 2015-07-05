require "faraday_csrf/version"
require "faraday_csrf/token_injector"
require 'faraday_csrf/token_extractors/meta_tag_regex_extractor'

module Faraday
  class CSRF
    attr_reader :app, :token, :extractor, :injector

    def initialize(app, options = {})
      @app = app
      @extractor = options[:extractor] || MetaTagRegexExtractor
      @injector = options[:injector] || TokenInjector.new
    end

    def call request_env
      injector.inject(token, into: request_env)

      app.call(request_env).on_complete do |response_env|
        response_env[:csrf_token] =
          extract_token_from response_env.body
      end
    end

    def extract_token_from(response_body)
      @token = extractor.extract_from(response_body)
    rescue Token::NotFound
      # welp, guess there isn't one
    end
  end
end

if Faraday::Middleware.respond_to? :register_middleware
  Faraday::Middleware.register_middleware :csrf => Faraday::CSRF
end
