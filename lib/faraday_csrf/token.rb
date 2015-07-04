require 'faraday'

module Faraday
  class CSRF
    class Token
      class NotFound < RuntimeError; end

      attr_reader :name, :value
      protected :name, :value

      def initialize(name: nil, value:)
        unless value
          raise ArgumentError.new 'Token must have a value'
        end

        @name = name || self.class.default_name
        @value = value
        @expired = false
      end

      def self.default_name
        'authenticity_token'
      end

      def expire!
        @name = nil
        @value = nil
        @expired = true
        self
      end

      def expired?
        @expired
      end

      def ==(other)
        name == other.name &&
          value == other.value &&
          expired? == other.expired?
      end

      alias_method :to_s, :value

      def inspect
        return "CSRF::Token(~expired~)" if expired?
        "CSRF::Token('#{name}' => '#{value}')"
      end

      def to_h
        return {} if expired?
        { name => value }
      end
    end
  end
end
