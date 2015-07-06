require 'faraday_csrf/token_extractors/composite_extractor'
require 'faraday_csrf/token_extractors/nokogiri_meta_tag_extractor'
require 'faraday_csrf/token_extractors/meta_tag_regex_extractor'

module Faraday
  class CSRF
    class DefaultExtractor
      def self.extractor
        CompositeExtractor.new([MetaTagRegexExtractor,
                                NokogiriMetaTagExtractor])
      end

      def self.extract_from(*args)
        extractor.extract_from(*args)
      end
    end
  end
end
