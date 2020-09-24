# frozen_string_literal: true
require 'dato/json_schema_relationships'

module Dato
  class JsonApiSerializer
    attr_reader :link, :type

    def initialize(type, link)
      @link = link
      @type = type
    end

    def serialize(resource, id = nil)
      resource = resource.with_indifferent_access
      data = {}

      data[:id] = id || resource[:id] if id || resource[:id]

      if resource.has_key?(:meta)
        resource.delete(:meta)
      end

      data[:type] = type
      data[:attributes] = serialized_attributes(resource)

      serialized_relationships = serialized_relationships(resource)

      if serialized_relationships
        data[:relationships] = serialized_relationships
      end

      { data: data }
    end

    def serialized_attributes(resource)
      result = {}

      attributes(resource).each do |attribute|
        if resource.key? attribute
          result[attribute] = resource[attribute]
        elsif required_attributes.include? attribute
          throw "Required attribute: #{attribute}"
        end
      end

      result
    end

    def serialized_relationships(resource)
      result = {}

      relationships.each do |relationship, meta|
        if resource.key? relationship
          value = resource[relationship]

          data = if value
                   if meta[:types].length > 1
                     if meta[:collection]
                       value.map(&:symbolize_keys)
                     else
                       value.symbolize_keys
                     end
                   else
                     type = meta[:types].first
                     if meta[:collection]
                       value.map do |id|
                         {
                           type: type,
                           id: id.to_s
                         }
                       end
                     else
                       {
                         type: type,
                         id: value.to_s
                       }
                     end
                   end
                 end

          result[relationship] = { data: data }
        elsif required_relationships.include?(relationship)
          throw "Required attribute: #{relationship}"
        end
      end

      result.empty? ? nil : result
    end

    def attributes(resource)
      if type == 'item'
        return resource.keys.map(&:to_sym) - %i[
          item_type
          id
          created_at
          updated_at
          creator
        ]
      end

      link_attributes['properties'].keys.map(&:to_sym)
    end

    def required_attributes
      return [] if type == 'item'

      (link_attributes.required || []).map(&:to_sym)
    end

    def relationships
      @relationships ||= JsonSchemaRelationships.new(link.schema).relationships
    end

    def required_relationships
      if link.schema.properties['data'].required.include?("relationships")
        (link_relationships.required || []).map(&:to_sym)
      else
        []
      end
    end

    def link_attributes
      link.schema.properties['data'].properties['attributes']
    end

    def link_relationships
      link.schema.properties['data'].properties['relationships']
    end
  end
end
