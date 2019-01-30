module Dato
  class JsonSchemaRelationships
    attr_reader :schema

    def initialize(schema)
      @schema = schema
    end

    def relationships
      if !schema || !schema.properties['data']
        return {}
      end

      entity = if schema.properties['data'].type.first == 'array'
                 schema.properties['data'].items
               else
                 schema.properties['data']
               end

      if !entity || !entity.properties['relationships'] || !entity.properties['relationships']
        return {}
      end

      relationships = entity.properties['relationships'].properties

      relationships.each_with_object({}) do |(relationship, schema), acc|
        is_collection = schema.properties['data'].type.first == 'array'

        types = if is_collection
                       [type(schema.properties['data'].items)]
                     elsif schema.properties['data'].type.first == 'object'
                       [type(schema.properties['data'])]
                     else
                       schema.properties['data'].any_of.map do |option|
                         type(option)
                       end.compact
                     end

        acc[relationship.to_sym] = {
          collection: is_collection,
          types: types
        }
      end
    end

    def type(definition)
      if definition.properties['type']
        definition.properties['type'].pattern.source.gsub(/(^\^|\$$)/, '')
      end
    end
  end
end
