# frozen_string_literal: true
require 'dato/site/repo/base'

module Dato
  module Site
    module Repo
      class MenuItem < Base
        def create(resource_attributes)
          body = JsonApiSerializer.new(
            type: :menu_item,
            attributes: %i(label position),
            relationships: { item_type: { collection: false, type: :item_type }, parent: { collection: false, type: :menu_item } },
            required_attributes: %i(label position)
          ).serialize(resource_attributes)

          post_request '/menu-items', body
        end

        def update(menu_item_id, resource_attributes)
          body = JsonApiSerializer.new(
            type: :menu_item,
            attributes: %i(label position),
            relationships: { item_type: { collection: false, type: :item_type }, parent: { collection: false, type: :menu_item } },
            required_attributes: %i(label position)
          ).serialize(resource_attributes, menu_item_id)

          put_request "/menu-items/#{menu_item_id}", body
        end

        def all
          get_request '/menu-items'
        end

        def find(menu_item_id)
          get_request "/menu-items/#{menu_item_id}"
        end

        def destroy(menu_item_id)
          delete_request "/menu-items/#{menu_item_id}"
        end
      end
    end
  end
end
