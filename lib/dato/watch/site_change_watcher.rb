# frozen_string_literal: true

require 'pusher-client'

module Dato
  module Watch
    class SiteChangeWatcher
      attr_reader :site_id

      PUSHER_API_KEY = '75e6ef0fe5d39f481626'

      def initialize(site_id)
        PusherClient.logger.level = Logger::WARN
        @site_id = site_id
        @socket = nil
      end

      def connect(&block)
        return if connected?

        @socket = PusherClient::Socket.new(PUSHER_API_KEY,
                                           secure: true,
                                           ws_host: 'ws-eu.pusher.com',
                                           auth_method: auth_method)
        @socket.subscribe("private-site-#{site_id}")
        @socket.bind('site:change', &block)
        @socket.connect(true)

        self
      end

      def connected?
        @socket && @socket.connected
      end

      def disconnect!
        connected? && @socket.disconnect
      end

      private

      def auth_method
        proc do |socket_id, channel|
          client = Dato::Site::Client.new(ENV['DATO_API_TOKEN'])
          client.pusher_token(socket_id, channel.name)['auth']
        end
      end
    end
  end
end
