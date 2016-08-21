# frozen_string_literal: true
require 'dato/site/repo/base'
require 'active_support/core_ext/hash/except'

module Dato
  module Site
    module Repo
      class Item < Base
        def create(resource_attributes)
          body = JsonApiSerializer.new(
            type: :item,
            attributes: resource_attributes.keys - [:item_type, :id],
            relationships: {
              item_type: { collection: false, type: 'item_type' }
            },
            required_relationships: %i(item_type)
          ).serialize(resource_attributes)

          post_request '/items', body
        end

        def update(item_id, resource_attributes)
          resource_attributes = resource_attributes.except(
            :id,
            :updated_at,
            :is_valid,
            :item_type
          )

          body = JsonApiSerializer.new(
            type: :item,
            attributes: resource_attributes.keys
          ).serialize(resource_attributes, item_id)

          put_request "/items/#{item_id}", body
        end

        def all(filters = {})
          get_request '/items', filters
        end

        def find(item_id)
          get_request "/items/#{item_id}"
        end

        def destroy(item_id)
          delete_request "/items/#{item_id}"
        end
      end
    end
  end
end
