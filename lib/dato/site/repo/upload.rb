# frozen_string_literal: true
require 'dato/site/repo/base'

module Dato
  module Site
    module Repo
      class Upload < Base
        def create(resource_attributes)
          body = JsonApiSerializer.new(
            type: :upload,
            attributes: %i(alt format height path size title width),
            required_attributes: %i(format path size)
          ).serialize(resource_attributes)

          post_request '/uploads', body
        end

        def all(query)
          get_request '/uploads', query
        end

        def find(upload_id)
          get_request "/uploads/#{upload_id}"
        end

        def destroy(upload_id)
          delete_request "/uploads/#{upload_id}"
        end

        def update(upload_id, resource_attributes)
          body = JsonApiSerializer.new(
            type: :upload,
            attributes: %i(alt title)
          ).serialize(resource_attributes, upload_id)

          put_request "/uploads/#{upload_id}", body
        end
      end
    end
  end
end
