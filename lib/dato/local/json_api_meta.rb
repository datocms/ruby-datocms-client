# frozen_string_literal: true

module Dato
  module Local
    class JsonApiMeta
      attr_reader :payload

      def initialize(payload)
        @payload = payload || {}
      end

      def [](key)
        @payload[key]
      end

      def respond_to_missing?(method, include_private = false)
        if @payload.key?(method)
          true
        else
          super
        end
      end

      private

      def method_missing(method, *arguments, &block)
        return super unless arguments.empty?

        if @payload.key?(method)
          @payload[method]
        else
          super
        end
      end
    end
  end
end
