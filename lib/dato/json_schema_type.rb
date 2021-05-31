# frozen_string_literal: true

module Dato
  class JsonSchemaType
    attr_reader :schema

    def initialize(schema)
      @schema = schema
    end

    def call
      type_property = find_info_for_type_property

      return nil unless type_property

      type_property.pattern.to_s.gsub(/(^(\(\?-mix:\^)|(\$\))$)/, "")
    end

    private

    def find_info_for_type_property
      entity = find_entity_in_data

      return nil unless entity

      entity.properties["type"]
    end

    def find_entity_in_data
      return nil if !schema || !schema.properties["data"]

      if schema.properties["data"].type.first == "array"
        return schema.properties["data"].items if schema.properties["data"].items

        return nil
      end

      return schema.properties["data"] if schema.properties["data"].type.first == "object"

      if schema.properties["data"].any_of
        return schema.properties["data"].any_of.reject { |x| x.definitions.type.example == "job" }
      end

      nil
    end
  end
end
