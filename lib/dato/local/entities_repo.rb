# frozen_string_literal: true

require 'dato/local/json_api_entity'

module Dato
  module Local
    class EntitiesRepo
      attr_reader :entities

      def initialize(*payloads)
        @entities = {}
        upsert_entities(*payloads)
      end

      def find_entities_of_type(type)
        entities.fetch(type, {}).values
      end

      def find_entity(type, id)
        entities.fetch(type, {}).fetch(id, nil)
      end

      def destroy_entities(type, ids)
        ids.each do |id|
          entities.fetch(type, {}).delete(id)
        end
      end

      def destroy_item_type(id)
        entities.fetch('item', {}).delete_if { |_item_id, item| item.item_type.id == id }
        entities.fetch('item_type', {}).delete(id)
      end

      def upsert_entities(*payloads)
        payloads.each do |payload|
          EntitiesRepo.payload_entities(payload).each do |entity_payload|
            object = JsonApiEntity.new(entity_payload, self)
            @entities[object.type] ||= {}
            @entities[object.type][object.id] = object
          end
        end
      end

      def self.payload_entities(payload)
        acc = []

        if payload[:data]
          acc = if payload[:data].is_a? Array
                  acc + payload[:data]
                else
                  acc + [payload[:data]]
                end
        end

        acc += payload[:included] if payload[:included]

        acc
      end
    end
  end
end
