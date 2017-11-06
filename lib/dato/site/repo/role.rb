# frozen_string_literal: true
require 'dato/site/repo/base'

module Dato
  module Site
    module Repo
      class Role < Base
        def create(resource_attributes)
          body = JsonApiSerializer.new(
            type: :role,
            attributes: %i(can_edit_favicon can_edit_schema can_edit_site can_manage_access_tokens can_manage_users can_perform_site_search can_publish_to_production can_publish_to_staging name negative_item_type_permissions positive_item_type_permissions),
            required_attributes: %i(can_edit_favicon can_edit_schema can_edit_site can_manage_access_tokens can_manage_users can_perform_site_search can_publish_to_production can_publish_to_staging name negative_item_type_permissions positive_item_type_permissions)
          ).serialize(resource_attributes)

          post_request '/roles', body
        end

        def update(role_id, resource_attributes)
          body = JsonApiSerializer.new(
            type: :role,
            attributes: %i(can_edit_favicon can_edit_schema can_edit_site can_manage_access_tokens can_manage_users can_perform_site_search can_publish_to_production can_publish_to_staging name negative_item_type_permissions positive_item_type_permissions),
            required_attributes: %i(can_edit_favicon can_edit_schema can_edit_site can_manage_access_tokens can_manage_users can_perform_site_search can_publish_to_production can_publish_to_staging name negative_item_type_permissions positive_item_type_permissions)
          ).serialize(resource_attributes, role_id)

          put_request "/roles/#{role_id}", body
        end

        def all
          get_request '/roles'
        end

        def find(role_id)
          get_request "/roles/#{role_id}"
        end

        def destroy(role_id)
          delete_request "/roles/#{role_id}"
        end
      end
    end
  end
end
