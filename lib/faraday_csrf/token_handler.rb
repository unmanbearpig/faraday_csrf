require "faraday_csrf/token_fetcher"
require "faraday_csrf/injects_token_into_body"

module Faraday
  class CSRF
    class TokenHandler
      attr_accessor :token

      def initialize(extractor:, injector:, fetcher:)
        @extractor = extractor
        @injector = injector
        @fetcher = fetcher
      end

      def handle_request request_env
        @injector.inject(@token, into: request_env)
      rescue InjectsTokenIntoBody::MissingToken
        @fetcher.call request_env
        retry
      end

      def handle_response response_env
        @token = @extractor.extract_from(response_env.body)
      rescue Token::NotFound
        nil
      end
    end
  end
end
