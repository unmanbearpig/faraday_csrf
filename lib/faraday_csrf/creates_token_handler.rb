require 'faraday_csrf/token_handler'
require 'faraday_csrf/token_extractors/meta_tag_regex_extractor'
require 'faraday_csrf/token_extractors/meta_tag_nokogiri_extractor'

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
        TokenHandler.new extractor: extractor,
                         injector: injector,
                         fetcher: fetcher
      end

      def extractors_to_try
        [MetaTagRegexExtractor,
         MetaTagNokogiriExtractor]
      end

      def extractor
        CompositeExtractor.new(extractors_to_try)
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
