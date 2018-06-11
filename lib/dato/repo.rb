# frozen_string_literal: true
require 'dato/json_api_serializer'
require 'dato/json_api_deserializer'
require 'dato/paginator'

module Dato
  class Repo
    attr_reader :client, :type, :schema

    IDENTITY_REGEXP = /\{\(.*?definitions%2F(.*?)%2Fdefinitions%2Fidentity\)}/

    METHOD_NAMES = {
      "instances" => :all,
      "self" => :find,
    }

    def initialize(client, type, schema)
      @client = client
      @type = type
      @schema = schema

      schema.links.each do |link|
        method_name = METHOD_NAMES.fetch(link.rel, link.rel)

        self.define_singleton_method(method_name) do |*args|
          min_arguments_count = [
            link.href.scan(IDENTITY_REGEXP).size,
            link.schema && link.method != :get ? 1 : 0
          ].reduce(0, :+)

          args.size >= min_arguments_count or
            raise ArgumentError.new(
              "wrong number of arguments (given #{args.size}, expected #{min_arguments_count})"
          )

          last_url_id = nil

          url = link["href"].gsub(IDENTITY_REGEXP) do |_stuff|
            last_url_id = args.shift.to_s
          end

          response = if %i(post put).include?(link.method)
            body = if link.schema
              unserialized_body = args.shift

              JsonApiSerializer.new(type, link).serialize(
                unserialized_body,
                last_url_id
              )
            else
              {}
            end

            client.request(link.method, url, body)

          elsif link.method == :delete
            client.request(:delete, url)

          elsif link.method == :get
            query_string = args.shift

            all_pages = (args[0] || {}).
              symbolize_keys.
              fetch(:all_pages, false)

            is_paginated_endpoint = link.schema &&
              link.schema.properties.has_key?("page[limit]")

            if is_paginated_endpoint && all_pages
              Paginator.new(client, url, query_string).response
            else
              client.request(:get, url, query_string)
            end
          end

          options = if args.any?
                      args.shift.symbolize_keys
                    else
                      {}
                    end

          if options.fetch(:deserialize_response, true)
            JsonApiDeserializer.new.deserialize(response)
          else
            response
          end
        end
      end
    end
  end
end
