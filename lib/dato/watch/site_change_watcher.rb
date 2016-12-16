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

        @socket = PusherClient::Socket.new(PUSHER_API_KEY, secure: true)
        @socket.subscribe("site-#{site_id}")
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
    end
  end
end
