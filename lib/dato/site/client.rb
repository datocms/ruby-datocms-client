require 'faraday'
require 'faraday_middleware'
require 'json'
require 'active_support/core_ext/hash/indifferent_access'

require 'dato/site/repo/field'
require 'dato/site/repo/item_type'
require 'dato/site/repo/menu_item'
require 'dato/site/repo/site'
require 'dato/site/repo/upload_request'
require 'dato/site/repo/user'
require 'dato/site/repo/item'

module Dato
  module Site
    class Client
      REPOS = {
        fields: Repo::Field,
        item_types: Repo::ItemType,
        menu_items: Repo::MenuItem,
        site: Repo::Site,
        upload_requests: Repo::UploadRequest,
        users: Repo::User,
        items: Repo::Item,
      }

      attr_reader :token, :domain, :schema

      def initialize(token, domain: 'http://site-api.datocms.com')
        @domain = domain
        @token = token
      end

      REPOS.each do |method_name, repo_klass|
        define_method method_name do
          instance_variable_set(
            "@#{method_name}",
            instance_variable_get("@#{method_name}") ||
            repo_klass.new(self)
          )
        end
      end

      def request(*args)
        begin
          connection.send(*args).body.with_indifferent_access
        rescue Faraday::ClientError => e
          body = JSON.parse(e.response[:body])
          puts JSON.pretty_generate(body)
          raise e
        end
      end

      private

      def connection
        options = {
          url: domain,
          headers: {
            'Accept' => "application/json",
            'Content-Type' => "application/json",
            'Authorization' => "Bearer #{@token}"
          }
        }

        @connection ||= Faraday.new(options) do |c|
          c.request :json
          c.response :json, content_type: /\bjson$/
          c.response :raise_error
          c.adapter :net_http
        end
      end
    end
  end
end
