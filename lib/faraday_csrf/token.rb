require 'faraday'

module Faraday
  class CSRF
    class Token
      class NotFound < RuntimeError; end

      attr_reader :name, :value

      def initialize(name: nil, value:)
        unless value
          raise ArgumentError.new 'Token must have a value'
        end

        @name = name || self.class.default_name
        @value = value
      end

      def self.default_name
        'authenticity_token'
      end

      def ==(other)
        name == other.name &&
          value == other.value
      end

      alias_method :to_s, :value

      def inspect
        "CSRF::Token('#{name}' => '#{value}')"
      end

      def to_h
        { name => value }
      end
    end
  end
end
