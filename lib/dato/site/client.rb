# frozen_string_literal: true

require 'dato/api_client'
require 'dato/upload/file'
require 'dato/upload/create_upload_path'

module Dato
  module Site
    class Client
      include ApiClient

      json_schema 'site-api'

      def create_upload_path(path_or_url)
        file = Upload::CreateUploadPath.new(self, path_or_url)
        file.upload_path
      end

      def upload_file(path_or_url, upload_attributes = {}, field_attributes = {})
        file = Upload::File.new(self, path_or_url, upload_attributes, field_attributes)
        file.upload
      end

      def upload_image(path_or_url, upload_attributes = {}, field_attributes = {})
        file = Upload::File.new(self, path_or_url, upload_attributes, field_attributes)
        file.upload
      end

      def pusher_token(socket_id, channel)
        request(
          :post,
          "/pusher/authenticate",
          { socket_id: socket_id, channel_name: channel}
        )
      end
    end
  end
end
