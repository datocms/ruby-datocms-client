# frozen_string_literal: true

require "faraday"
require "faraday_middleware"
require "json"
require "json_schema"

require "dato/version"
require "dato/repo"

require "dato/api_error"

require "cacert"

module Dato
  module ApiClient
    def self.included(base)
      base.extend ClassMethods

      base.class_eval do
        attr_reader :token, :environment, :base_url, :schema, :extra_headers
      end
    end

    module ClassMethods
      def json_schema(subdomain)
        define_method(:initialize) do |token, options = {}|
          @token = token
          @base_url = options[:base_url] || "https://#{subdomain}.datocms.com"
          @environment = options[:environment]
          @extra_headers = options[:extra_headers] || {}
        end

        define_singleton_method(:subdomain) do
          subdomain
        end
      end
    end

    def respond_to_missing?(method, include_private = false)
      json_schema.definitions.each do |type, obj|
        is_collection = obj.links.select { |x| x.rel == "instances" }.any?
        namespace = is_collection ? type.pluralize : type
        return true if method.to_s == namespace
      end

      super
    end

    def method_missing(method, *args, &block)
      json_schema.definitions.each do |type, obj|
        is_collection = obj.links.select { |x| x.rel == "instances" }.any?
        namespace = is_collection ? type.pluralize : type

        next unless method.to_s == namespace

        instance_variable_set(
          "@#{namespace}",
          instance_variable_get("@#{namespace}") ||
          Dato::Repo.new(self, type, obj),
        )

        return instance_variable_get("@#{namespace}")
      end

      super
    end

    def json_schema
      @json_schema ||= begin
        response = Faraday.get(
          # "http://#{subdomain}.lvh.me:3001/docs/#{subdomain}-hyperschema.json"
          "#{base_url}/docs/#{self.class.subdomain}-hyperschema.json",
        )

        schema = JsonSchema.parse!(JSON.parse(response.body))
        schema.expand_references!

        schema
      end
    end

    def put(absolute_path, body = {}, params = {})
      request(:put, absolute_path, body, params)
    end

    def post(absolute_path, body = {}, params = {})
      request(:post, absolute_path, body, params)
    end

    def get(absolute_path, params = {})
      request(:get, absolute_path, nil, params)
    end

    def delete(absolute_path, params = {})
      request(:delete, absolute_path, nil, params)
    end

    def request(*args)
      method, absolute_path, body, params = args

      response = connection.send(method, absolute_path, body) do |c|
        c.params = params if params
      end

      response.body.with_indifferent_access if response.body.is_a?(Hash)
    rescue Faraday::SSLError => e
      raise e if ENV["SSL_CERT_FILE"] == Cacert.pem

      Cacert.set_in_env
      request(*args)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      puts e.message
      raise e
    rescue Faraday::ClientError => e
      if e.response[:status] == 429
        to_wait = e.response[:headers]["x-ratelimit-reset"].to_i
        puts "Rate limit exceeded, waiting #{to_wait} seconds..."
        sleep(to_wait + 1)
        request(*args)
      elsif e.response[:status] == 422 && batch_data_validation?(e.response)
        puts "Validating items, waiting 1 second and retrying..."
        sleep(1)
        request(*args)
      else
        # puts body.inspect
        # puts '===='
        # puts error.message
        # puts '===='
        error = ApiError.new(e.response)
        raise error
      end
    end

    private

    def batch_data_validation?(response)
      body = begin
        JSON.parse(response[:body])
      rescue JSON::ParserError
        nil
      end

      return false unless body
      return false unless body["data"]

      body["data"].any? do |e|
        e["attributes"]["code"] == "BATCH_DATA_VALIDATION_IN_PROGRESS"
      end
    rescue StandardError
      false
    end

    def connection
      default_headers = {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@token}",
        "User-Agent" => "ruby-client v#{Dato::VERSION}",
        "X-Api-Version" => "3",
      }

      default_headers.merge!("X-Environment" => environment) if environment

      options = {
        url: base_url,
        headers: default_headers.merge(extra_headers),
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
