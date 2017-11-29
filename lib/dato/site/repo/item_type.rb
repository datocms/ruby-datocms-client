# frozen_string_literal: true
require 'dato/site/repo/base'

module Dato
  module Site
    module Repo
      class ItemType < Base
        def create(resource_attributes)
          body = JsonApiSerializer.new(
            type: :item_type,
            attributes: %i(api_key modular_block name ordering_direction singleton sortable tree),
            relationships: { ordering_field: { collection: false, type: :field } },
            required_attributes: %i(api_key modular_block name ordering_direction singleton sortable tree),
            required_relationships: %i(ordering_field)
          ).serialize(resource_attributes)

          post_request '/item-types', body
        end

        def update(item_type_id, resource_attributes)
          body = JsonApiSerializer.new(
            type: :item_type,
            attributes: %i(api_key modular_block name ordering_direction singleton sortable tree),
            relationships: { ordering_field: { collection: false, type: :field } },
            required_attributes: %i(api_key modular_block name ordering_direction singleton sortable tree),
            required_relationships: %i(ordering_field)
          ).serialize(resource_attributes, item_type_id)

          put_request "/item-types/#{item_type_id}", body
        end

        def all
          get_request '/item-types'
        end

        def find(item_type_id)
          get_request "/item-types/#{item_type_id}"
        end

        def duplicate(item_type_id)
          post_request "/item-types/#{item_type_id}/duplicate"
        end

        def destroy(item_type_id)
          delete_request "/item-types/#{item_type_id}"
        end
      end
    end
  end
end
