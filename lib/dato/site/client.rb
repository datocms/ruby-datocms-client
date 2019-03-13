# frozen_string_literal: true

require 'dato/api_client'
require 'dato/upload/file'
require 'dato/upload/image'

module Dato
  module Site
    class Client
      include ApiClient

      json_schema 'site-api'

      def upload_file(path_or_url)
        file = Upload::File.new(self, path_or_url)
        file.upload
      end

      def upload_image(path_or_url)
        file = Upload::Image.new(self, path_or_url)
        file.upload
      end

      def pusher_token(socket_id, channel)
        request(:post, '/pusher/authenticate', {socket_id: socket_id, channel_name: channel})
      end
    end
  end
end
