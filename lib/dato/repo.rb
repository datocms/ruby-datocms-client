# frozen_string_literal: true

require 'dato/json_api_serializer'
require 'dato/json_api_deserializer'
require 'dato/paginator'

module Dato
  class Repo
    attr_reader :client, :type, :schema

    IDENTITY_REGEXP = /\{\(.*?definitions%2F(.*?)%2Fdefinitions%2Fidentity\)}/.freeze

    METHOD_NAMES = {
      'instances' => :all,
      'self' => :find
    }.freeze

    def initialize(client, type, schema)
      @client = client
      @type = type
      @schema = schema
    end

    def respond_to_missing?(method, include_private = false)
      respond_to_missing = schema.links.any? do |link|
        METHOD_NAMES.fetch(link.rel, link.rel).to_sym == method.to_sym
      end

      respond_to_missing || super
    end

    private

    def method_missing(method, *args, &block)
      link = schema.links.find do |link|
        METHOD_NAMES.fetch(link.rel, link.rel).to_sym == method.to_sym
      end

      return super unless link

      min_arguments_count = [
        link.href.scan(IDENTITY_REGEXP).size,
        link.schema && link.method != :get ? 1 : 0
      ].reduce(0, :+)

      (args.size >= min_arguments_count) ||
        raise(ArgumentError, "wrong number of arguments (given #{args.size}, expected #{min_arguments_count})")

      placeholders = []

      url = link['href'].gsub(IDENTITY_REGEXP) do |_stuff|
        placeholder = args.shift.to_s
        placeholders << placeholder
        placeholder
      end

      body = nil
      query_string = nil

      if %i[post put].include?(link.method)
        body = link.schema ? args.shift : {}
        query_string = args.shift || {}

      elsif link.method == :delete
        query_string = args.shift || {}

      elsif link.method == :get
        query_string = args.shift || {}
      end

      options = args.any? ? args.shift.symbolize_keys : {}

      if link.schema && %i[post put].include?(link.method) && options.fetch(:serialize_response, true)
        body = JsonApiSerializer.new(link: link).serialize(
          body,
          link.method == :post ? nil : placeholders.last
        )
      end

      response = if %i[post put].include?(link.method)
                   client.send(link.method, url, body, query_string)
                 elsif link.method == :delete
                   client.delete(url, query_string)
                 elsif link.method == :get
                   if options.fetch(:all_pages, false)
                     Paginator.new(client, url, query_string).response
                   else
                     client.get(url, query_string)
                   end
                 end

      if response && response[:data] && response[:data].is_a?(Hash) && response[:data][:type] == 'job'
        job_result = nil

        until job_result
          begin
            sleep(1)
            job_result = client.job_result.find(response[:data][:id])
          rescue ApiError => e
            raise e if e.response[:status] != 404
          end
        end

        if job_result[:status] < 200 || job_result[:status] >= 300
          error = ApiError.new(
            status: job_result[:status],
            body: JSON.dump(job_result[:payload])
          )

          puts '===='
          puts error.message
          puts '===='

          raise error
        end

        if options.fetch(:deserialize_response, true)
          JsonApiDeserializer.new(link.job_schema).deserialize(job_result[:payload])
        else
          job_result.payload
        end
      else
        if options.fetch(:deserialize_response, true)
          JsonApiDeserializer.new(link.target_schema).deserialize(response)
        else
          response
        end
      end
    end
  end
end
