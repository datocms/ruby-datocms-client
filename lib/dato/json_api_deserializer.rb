# frozen_string_literal: true

require "dato/json_schema_relationships"

module Dato
  class JsonApiDeserializer
    attr_reader :schema

    def initialize(schema)
      @schema = schema
    end

    def deserialize(data)
      return nil unless data

      data = data[:data]

      if data.is_a? Array
        data.map { |resource| deserialize_resource(resource) }
      else
        deserialize_resource(data)
      end
    end

    def deserialize_resource(data)
      result = { id: data[:id] }
      result[:meta] = data[:meta] if data[:meta]
      result.merge!(data[:attributes]) if data[:attributes]

      if data[:relationships]
        relationships.each do |relationship, meta|
          next unless data[:relationships][relationship]

          rel_data = data[:relationships][relationship][:data]

          result[relationship] = if meta[:types].length > 1
                                   rel_data
                                 elsif !rel_data
                                   nil
                                 elsif meta[:collection]
                                   rel_data.map { |ref| ref[:id] }
                                 else
                                   rel_data[:id]
                                 end
        end
      end

      result.with_indifferent_access
    end

    def relationships
      @relationships ||= JsonSchemaRelationships.new(schema).relationships
    end
  end
end
