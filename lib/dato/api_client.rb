require 'faraday'
require 'faraday_middleware'
require 'json'
require 'json_schema'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/inflector'

require 'dato/version'
require 'dato/repo'

require 'dato/api_error'

require 'cacert'

module Dato
  module ApiClient
    def self.included(base)
      base.extend ClassMethods

      base.class_eval do
        attr_reader :token, :base_url, :schema, :extra_headers
      end
    end

    module ClassMethods
      def json_schema(subdomain)
        define_method(:initialize) do |token, options = {}|
          @token = token
          @base_url = options[:base_url] || "https://#{subdomain}.datocms.com"
          @extra_headers = options[:extra_headers] || {}
        end

        url = URI.parse("https://#{subdomain}.datocms.com/docs/#{subdomain}-hyperschema.json")
        response = Net::HTTP.get(url)

        schema = JsonSchema.parse!(JSON.parse(response))
        schema.expand_references!

        schema.definitions.each do |type, schema|
          is_collection = schema.links.select{|x| x.rel === "instances"}.any?

          if is_collection
            type = type.pluralize
          end

          define_method(type) do
            instance_variable_set(
              "@#{type}",
              instance_variable_get("@#{type}") ||
              Dato::Repo.new(self, type, schema)
            )
          end
        end
      end
    end

    def request(*args)
      connection.send(*args).body.with_indifferent_access
    rescue Faraday::SSLError => e
      raise e if ENV['SSL_CERT_FILE'] == Cacert.pem

      Cacert.set_in_env
      request(*args)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      puts e.message
      raise e
    rescue Faraday::ClientError => e
      error = ApiError.new(e)
      puts '===='
      puts error.message
      puts '===='
      raise error
    end

    private

    def connection
      options = {
        url: base_url,
        headers: extra_headers.merge(
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@token}",
          'User-Agent' => "ruby-client v#{Dato::VERSION}",
          'X-Api-Version' => "2"
        )
      }

      @connection ||= Faraday.new(options) do |c|
        c.request :json
        c.response :json, content_type: /\bjson$/
        c.response :raise_error
        c.use FaradayMiddleware::FollowRedirects
        c.adapter :net_http
      end
    end
  end
end

module AugmentWithRepos
  def self.do_it!(klass, url)
  end
end

module Dato
  class BaseClient


  end
end
