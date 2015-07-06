require 'faraday_csrf/token_extractors/nokogiri_extractor'

module Faraday
  class CSRF
    class NokogiriMetaTagExtractor < NokogiriExtractor
      protected

      def name
        find('meta[name=csrf-param]').attr('content').text
      rescue Token::NotFound
        nil
      end

      def value
        find('meta[name=csrf-token]').attr('content').text
      end
    end
  end
end
