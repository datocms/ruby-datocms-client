# frozen_string_literal: true
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

      data[:type] = type
      data[:attributes] = serialized_attributes(resource)

      if relationships.any?
        data[:relationships] = serialized_relationships(resource)
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
                   if meta[:collection]
                     value.map do |id|
                       { type: meta[:type], id: id.to_s }
                     end
                   else
                     { type: meta[:type], id: value.to_s }
                   end
                 end
          result[relationship] = { data: data }

        elsif required_relationships.include?(relationship)
          throw "Required attribute: #{relationship}"
        end
      end

      result
    end

    def attributes(resource)
      if type == "item"
        return resource.keys.map(&:to_sym) - [
          :item_type,
          :id,
          :created_at,
          :updated_at,
          :is_valid,
          :published_version,
          :current_version
        ]
      end

      link_attributes["properties"].keys.map(&:to_sym)
    end

    def required_attributes
      if type == "item"
        return []
      end

      (link_attributes.required || []).map(&:to_sym)
    end

    def relationships
      if type == "item"
        if link.rel == :create
          return { item_type: { collection: false, type: 'item_type' } }
        else
          {}
        end
      end

      if !link_relationships
        return {}
      end

      link_relationships.properties.reduce({}) do |acc, (relationship, schema)|
        is_collection = schema.properties["data"].type.first == 'array'

        definition = if is_collection
                       schema.properties['data'].items
                     elsif schema.properties['data'].type.first == 'object'
                       schema.properties['data']
                     else
                       schema.properties['data'].any_of.find do |option|
                         option.type.first == 'object'
                       end
                     end

        type = definition.properties['type']
                         .pattern.source.gsub(/(^\^|\$$)/, '')

        acc[relationship.to_sym] = {
          collection: is_collection,
          type: type,
        }

        acc
      end
    end

    def required_relationships
      if type == "item"
        return %i(item_type)
      end

      (link_relationships.required || []).map(&:to_sym)
    end

    def link_attributes
      link.schema.properties["data"].properties["attributes"]
    end

    def link_relationships
      link.schema.properties["data"].properties["relationships"]
    end
  end
end
