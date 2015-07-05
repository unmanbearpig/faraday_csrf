require 'nokogiri'

module Faraday
  class CSRF
    class NokogiriExtractor
      attr_reader :document
      protected :document

      def initialize(document)
        @document = document
      end

      def self.extract_from html
        new(Nokogiri::HTML(html)).token
      end

      def token
        Token.new name: name,
                  value: value
      end

      protected

      def name
        raise NotImplementedError
      end

      def value
        raise NotImplementedError
      end

      def find(css)
        search_result = document.css(css)

        unless search_result.any?
          raise Token::NotFound.new(
                  "Could not find element with selector '#{css}'")
        end

        search_result
      end
    end
  end
end
