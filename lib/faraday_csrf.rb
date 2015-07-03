require "faraday_csrf/version"
require 'faraday_csrf/token_extractors/meta_tag_regex_extractor'

module Faraday
  class CSRF
    attr_reader :app, :extractor, :token

    def initialize(app, extractor = MetaTagRegexExtractor)
      @app = app
      @extractor = extractor
    end

    def call request_env
      if should_inject_token? request_env
        inject_token_into request_env
      end

      app.call(request_env).on_complete do |response_env|
        response_env[:csrf_token] =
          extract_token_from response_env.body
      end
    end

    def should_inject_token? request_env
      request_env.method == :post
    end

    def extract_token_from(response_body)
      @token = extractor.extract_from(response_body)
    rescue Token::NotFound
      # welp, guess there isn't one
    end

    def inject_token_into request_env
      request_env.body.merge! token.to_h
      @token = nil
    end
  end
end
