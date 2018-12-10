module Dato
  class JsonSchemaRelationships
    attr_reader :link

    def initialize(link)
      @link = link
    end

    def relationships
      return {} unless link

      link.properties.each_with_object({}) do |(relationship, schema), acc|
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
