require 'faraday_csrf/token_handler'

module Faraday
  class CSRF
    class CreatesTokenHandler
      def initialize(app:, fetch_token_from_url: nil)
        @app = app
        @fetch_token_from_url = fetch_token_from_url
      end

      def self.create *args
        new(*args).token_handler
      end

      def token_handler
        TokenHandler.new extractor: DefaultExtractor,
                         injector: TokenInjector.new,
                         fetcher: fetcher
      end

      def extractor
        DefaultExtractor
      end

      def injector
        TokenInjector.new
      end

      def fetcher
        if @fetch_token_from_url
          TokenFetcher.new app: @app, url: @fetch_token_from_url
        else
          Proc.new {}
        end
      end
    end
  end
end
