# frozen_string_literal: true

require 'dato/json_api_serializer'

module Dato
  module Utils
    module BuildModularBlock
      def self.build(unserialized_body)
        json_api_serializer = JsonApiSerializer.new(type: 'item')
        attributes = json_api_serializer.serialized_attributes(unserialized_body)

        payload = {
          type: 'item',
          attributes: attributes,
          relationships: {
            item_type: {
              data: {
                id: unserialized_body[:item_type],
                type: 'item_type'
              }
            }
          }
        }

        payload[:id] = unserialized_body[:id] if unserialized_body[:id]

        payload
      end
    end
  end
end
