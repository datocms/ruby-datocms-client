# frozen_string_literal: true
require 'dato/account/repo/base'

module Dato
  module Account
    module Repo
      class Account < Base
        def update(resource_attributes)
          body = JsonApiSerializer.new(
            type: :account,
            attributes: %i(email password)
          ).serialize(resource_attributes)

          put_request '/account', body
        end

        def find
          get_request '/account'
        end
      end
    end
  end
end
