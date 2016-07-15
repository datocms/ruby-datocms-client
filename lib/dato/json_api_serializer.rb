module Dato
  class JsonApiSerializer
    attr_reader :type, :attributes, :relationships
    attr_reader :required_attributes, :required_relationships

    def initialize(
      type:,
      attributes: [],
      required_attributes: [],
      relationships: {},
      required_relationships: []
    )
      @type = type
      @attributes = attributes
      @required_attributes = required_attributes
      @relationships = relationships
      @required_relationships = required_relationships
    end

    def serialize(resource, id = nil)
      resource = resource.with_indifferent_access
      data = {}

      if id || resource[:id]
        data[:id] = id || resource[:id]
      end

      data[:type] = type
      data[:attributes] = serialized_attributes(resource)

      if relationships.any?
        data[:relationships] = serialized_relationships(resource)
      end

      { data: data }
    end

    def serialized_attributes(resource)
      result = {}

      attributes.each do |attribute|
        if resource.has_key? attribute
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
        if resource.has_key? relationship
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

        elsif required_relationships.include? relationship
          throw "Required attribute: #{relationship}"
        end
      end

      result
    end
  end
end
