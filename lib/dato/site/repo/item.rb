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

        def all(filters = {}, deserialize_response = true)
          items_per_page = 500

          base_response = client.request(
            :get, '/items', filters.dup.merge('page[limit]' => items_per_page)
          )

          extra_pages = (
            base_response[:meta][:total_count] / items_per_page.to_f
          ).ceil - 1

          extra_pages.times do |page|
            base_response[:data] += client.request(
              :get,
              '/items',
              filters.dup.merge(
                'page[offset]' => items_per_page * (page + 1),
                'page[limit]' => items_per_page
              )
            )[:data]
          end

          if deserialize_response
            JsonApiDeserializer.new.deserialize(base_response)
          else
            base_response
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
