# frozen_string_literal: true

require 'dato/api_client'

module Dato
  module Account
    class Client
      include ApiClient

      json_schema 'account-api'
    end
  end
end
