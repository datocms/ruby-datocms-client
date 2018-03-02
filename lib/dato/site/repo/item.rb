# frozen_string_literal: true
require 'dato/site/repo/base'
require 'dato/site/paginator'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/keys'

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
            :created_at,
            :is_valid,
            :item_type,
            :published_version,
            :current_version
          )

          body = JsonApiSerializer.new(
            type: :item,
            attributes: resource_attributes.keys
          ).serialize(resource_attributes, item_id)

          put_request "/items/#{item_id}", body
        end

        def publish(item_id)
          put_request "/items/#{item_id}/publish", {}
        end

        def unpublish(item_id)
          put_request "/items/#{item_id}/unpublish", {}
        end

        def all(filters = {}, options = {})
          options.symbolize_keys!

          deserialize_response = options.fetch(:deserialize_response, true)
          all_pages = options.fetch(:all_pages, false)

          response = if all_pages
            Paginator.new(client, '/items', filters).response
          else
            client.request(:get, '/items', filters)
          end

          if deserialize_response
            JsonApiDeserializer.new.deserialize(response)
          else
            response
          end
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
