# frozen_string_literal: true
require 'dato/site/repo/base'

module Dato
  module Site
    module Repo
      class Field < Base
        def create(item_type_id, resource_attributes)
          body = JsonApiSerializer.new(
            type: :field,
            attributes: %i(api_key appeareance field_type hint label localized position validators),
            required_attributes: %i(api_key appeareance field_type hint label localized position validators)
          ).serialize(resource_attributes)

          post_request "/item-types/#{item_type_id}/fields", body
        end

        def update(field_id, resource_attributes)
          body = JsonApiSerializer.new(
            type: :field,
            attributes: %i(api_key appeareance field_type hint label localized position validators)
          ).serialize(resource_attributes, field_id)

          put_request "/fields/#{field_id}", body
        end

        def all(item_type_id)
          get_request "/item-types/#{item_type_id}/fields"
        end

        def find(field_id)
          get_request "/fields/#{field_id}"
        end

        def destroy(field_id)
          delete_request "/fields/#{field_id}"
        end
      end
    end
  end
end
