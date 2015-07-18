require 'faraday_csrf/token'

module Faraday
  class CSRF
    class FirstSuccessfulExtractor
      attr_reader :extractors

      def initialize(extractors_to_try)
        @extractors = extractors_to_try
        unless extractors.any?
          raise ArgumentError.new "Pass at least one extractor into FirstSuccessfulExtractor"
        end
      end

      def extract_from input_data
        results = extractors.lazy
                  .map { |x| call_it x, input_data }
                  .reject(&:nil?)

        if results.any?
          results.first
        else
          raise Token::NotFound.new "None of the extractors #{extractors} could find a token"
        end
      end

      private

      def call_it extractor, input_data
        extractor.extract_from(input_data)
      rescue Token::NotFound
        # just skip it
      end
    end
  end
end
