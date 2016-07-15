module Dato
  class JsonApiDeserializer
    def deserialize(data)
      data = data[:data]

      if data.is_a? Array
        data.map { |resource| deserialize_resource(resource) }
      else
        deserialize_resource(data)
      end
    end

    def deserialize_resource(data)
      result = { id: data[:id] }
      result.merge!(data[:attributes])

      relationships = data.delete(:relationships)

      if relationships
        relationships.each do |key, data|
          data = data["data"]
          value = if data.is_a? Array
                    data.map { |ref| ref["id"] }
                  elsif data.is_a? Hash
                    data[:id]
                  else
                    nil
                  end
          result[key] = value
        end
      end

      result.with_indifferent_access
    end
  end
end

