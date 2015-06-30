require 'faraday'

module Faraday
  class CSRF
    class Token < Struct.new(:name, :value)
      attr_reader :name, :value
      def initialize(name: 'authenticity_token', value:)
        @name = name
        @value = value
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
