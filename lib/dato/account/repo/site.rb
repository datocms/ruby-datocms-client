# frozen_string_literal: true
require 'dato/account/repo/base'

module Dato
  module Account
    module Repo
      class Site < Base
        def find(site_id)
          get_request "/sites/#{site_id}"
        end

        def all
          get_request '/sites'
        end

        def create(resource_attributes)
          body = JsonApiSerializer.new(
            type: :site,
            attributes: %i(domain internal_subdomain name notes ssg template)
          ).serialize(resource_attributes)

          post_request '/sites', body
        end

        def update(site_id, resource_attributes)
          body = JsonApiSerializer.new(
            type: :site,
            attributes: %i(domain internal_subdomain name notes)
          ).serialize(resource_attributes, site_id)

          put_request "/sites/#{site_id}", body
        end

        def destroy(site_id)
          delete_request "/sites/#{site_id}"
        end

        def duplicate(site_id, resource_attributes)
          body = JsonApiSerializer.new(
            type: :site,
            attributes: %i(name)
          ).serialize(resource_attributes)

          post_request "/sites/#{site_id}/duplicate", body
        end
      end
    end
  end
end
