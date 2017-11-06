# frozen_string_literal: true
require 'dato/site/repo/base'

module Dato
  module Site
    module Repo
      class AccessToken < Base
        def create(resource_attributes)
          body = JsonApiSerializer.new(
            type: :access_token,
            attributes: %i(name),
            relationships: { role: { collection: false, type: :role } },
            required_attributes: %i(name)
          ).serialize(resource_attributes)

          post_request '/access_tokens', body
        end

        def update(user_id, resource_attributes)
          body = JsonApiSerializer.new(
            type: :access_token,
            attributes: %i(name),
            relationships: { role: { collection: false, type: :role } }
          ).serialize(resource_attributes, user_id)

          put_request "/access_tokens/#{user_id}", body
        end

        def all
          get_request '/access_tokens'
        end

        def find(user_id)
          get_request "/access_tokens/#{user_id}"
        end

        def regenerate_token(user_id)
          post_request "/access_tokens/#{user_id}/regenerate_token"
        end

        def destroy(user_id)
          delete_request "/access_tokens/#{user_id}"
        end
      end
    end
  end
end
