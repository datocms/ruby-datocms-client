# frozen_string_literal: true

require 'mime/types'
require 'tempfile'
require 'addressable'
require 'net/http'

module Dato
  module Upload
    class File
      IMAGE_FORMATS = %w[png jpg jpeg gif].freeze

      attr_reader :client, :source

      def initialize(client, source)
        @client = client
        @source = source
      end

      def file
        @file ||= if http_source?
                    uri = Addressable::URI.parse(source)
                    ext = ::File.extname(uri.path).downcase
                    tempfile = Tempfile.new(['file', ext])
                    tempfile.binmode
                    tempfile.write(download_file(source))
                    tempfile.rewind
                    tempfile
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
        upload_request = client.upload_request.create(filename: filename)
        uri = URI.parse(upload_request[:url])

        mime_type = MIME::Types.of(filename).first

        request = Net::HTTP::Put.new(uri)
        if mime_type
          request.add_field("Content-Type", mime_type.to_s)
        end
        request.body = file.read

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        http.request(request)

        upload = client.uploads.create(path: upload_request[:id])

        {
          upload_id: upload['id'],
          alt: nil,
          title: nil,
          custom_data: {},
        }
      end

      def download_file(url)
        connection = Faraday.new do |c|
          c.response :raise_error
          c.use FaradayMiddleware::FollowRedirects
          c.adapter :net_http
        end
        connection.get(url).body
      rescue Faraday::Error => e
        puts "Error during uploading #{url}"
        raise e
      end
    end
  end
end
