require "dato/json_api_serializer"
require "dato/json_api_deserializer"

module Dato
  module Account
    module Repo
      class Base
        attr_reader :client

        def initialize(client)
          @client = client
        end

        private

        %i(post put delete get).each do |method|
          define_method "#{method}_request" do |*args|
            JsonApiDeserializer.new.deserialize(
              client.request(method, *args)
            )
          end
        end
      end
    end
  end
end

