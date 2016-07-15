require 'dato/account/repo/base'

module Dato
  module Account
    module Repo
      class Account < Base

        def create(resource_attributes)
          body = JsonApiSerializer.new(
            type: :account,
            attributes: %i(email password),
            required_attributes: %i(email password),
          ).serialize(resource_attributes)

          post_request "/account", body
        end

        def update(resource_attributes)
          body = JsonApiSerializer.new(
            type: :account,
            attributes: %i(email password),
          ).serialize(resource_attributes)

          put_request "/account", body
        end

        def find()
          get_request "/account"
        end

        def reset_password(resource_attributes)
          body = JsonApiSerializer.new(
            type: :account,
            attributes: %i(email),
            required_attributes: %i(email),
          ).serialize(resource_attributes)

          post_request "/account/reset_password", body
        end

      end
    end
  end
end
