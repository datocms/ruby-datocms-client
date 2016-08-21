# frozen_string_literal: true
require 'downloadr'
require 'tempfile'
require 'addressable'
require 'net/http'

module Dato
  module Upload
    class File
      attr_reader :client, :source

      def initialize(client, source)
        @client = client
        @source = source
      end

      def file
        @file ||= if http_source?
                    Tempfile.new('file').tap do |file|
                      Downloadr::HTTP.new(source, file).download
                    end
                  else
                    ::File.new(::File.expand_path(source))
                  end
      end

      def http_source?
        uri = Addressable::URI.parse(source)
        uri.scheme == 'http' || uri.scheme == 'https'
      rescue Addressable::URI::InvalidURIError
        false
      end

      def filename
        if http_source?
          ::File.basename(source)
        else
          ::File.basename(file.path)
        end
      end

      def upload
        upload_request = client.upload_requests.create(filename: filename)
        uri = URI.parse(upload_request[:url])

        request = Net::HTTP::Put.new(
          uri,
          'x-amz-acl' => 'public-read'
        )
        request.body = file.read

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        http.request(request)

        format_resource(upload_request)
      end

      def format_resource(upload_request)
        {
          path: upload_request[:id],
          size: ::File.size(file.path),
          format: ::File.extname(::File.basename(file.path)).delete('.')
        }
      end
    end
  end
end
