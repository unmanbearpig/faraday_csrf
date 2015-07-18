require 'faraday_csrf/token'

module Faraday
  class CSRF
    # Much faster than using Nokogiri
    # use it in combination with Nokogiri extractor,
    # since it might be not as robust
    class MetaTagRegexExtractor
      attr_reader :html

      class ExtractError < RuntimeError; end

      def initialize(html)
        @html = html
      end

      def value
        content_from_meta_tag('csrf-token')
      end

      def name
        content_from_meta_tag('csrf-param')
      rescue ExtractError
        nil
      end

      def token
        Token.new value: value, name: name
      rescue RuntimeError
        raise Token::NotFound.new 'Could not find CSRF token'
      end

      private

      def content_from_meta_tag tag_name
        content_from_tag(find_meta_tag(tag_name))
      end

      def find_meta_tag(name)
        html.match(/<meta [^>]*name="#{name}"[^>]+>/)[0]
      rescue NoMethodError
        raise ExtractError.new "Could not find meta tag with name '#{name}'"
      end

      def content_from_tag token_string
        token_string.match(/ content="([^"]+)"/)[1]
      rescue NoMethodError
        raise ExtractError.new "Could not find content inside the html tag '#{token_string}'"
      end

      class << self
        def extract_from html
          new(html).token
        end
      end
    end
  end
end
