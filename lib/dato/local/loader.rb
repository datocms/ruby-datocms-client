# frozen_string_literal: true

require 'dato/local/entities_repo'
require 'dato/local/items_repo'

module Dato
  module Local
    class Loader
      attr_reader :client
      attr_reader :entities_repo
      attr_reader :items_repo
      attr_reader :preview_mode

      PUSHER_API_KEY = '499361cac597e83970f7'

      def initialize(client, preview_mode = false)
        @client = client
        @preview_mode = preview_mode
        @entities_repo = EntitiesRepo.new
        @items_repo = ItemsRepo.new(@entities_repo)
      end

      def load
        threads = [
          Thread.new { Thread.current[:output] = site },
          Thread.new { Thread.current[:output] = all_items },
          Thread.new { Thread.current[:output] = all_uploads }
        ]

        results = threads.map do |t|
          t.join
          t[:output]
        end

        @entities_repo = EntitiesRepo.new(*results)
        @items_repo = ItemsRepo.new(@entities_repo)
      end

      def watch(site_id, &block)
        return if pusher && pusher.connected

        pusher.subscribe("private-site-#{site_id}")
        bind_on_item_destroy(&block)
        bind_on_item_upsert(&block)
        bind_on_itemtype_upsert(&block)
        bind_on_itemtype_destroy(&block)
        bind_on_upload_upsert(&block)
        bind_on_upload_destroy(&block)
        pusher.connect(true)
        self
      end

      def stop_watch
        pusher.disconnect if pusher && pusher.connected
      end

      private

      def bind_on_item_upsert
        event_type = preview_mode ? 'preview_mode' : 'published'
        pusher.bind("item:#{event_type}:upsert") do |data|
          item_ids = JSON.parse(data)['child_items_ids']
          item_ids << JSON.parse(data)['id']
          payload = client.items.all({
                                       'filter[ids]' => item_ids.join(','),
                                       version: preview_mode ? 'latest' : 'published'
                                     }, deserialize_response: false)
          @entities_repo.upsert_entities(payload)
          update_items_repo
          yield
        end
      end

      def bind_on_item_destroy
        event_type = preview_mode ? 'preview_mode' : 'published'
        pusher.bind("item:#{event_type}:destroy") do |data|
          @entities_repo.destroy_entity('item', JSON.parse(data)['id'])
          yield
        end
      end

      def bind_on_upload_upsert
        pusher.bind('upload:upsert') do |data|
          id << JSON.parse(data)['id']
          payload = client.items.find(id, {}, deserialize_response: false)
          @entities_repo.upsert_entities(payload)
          update_items_repo
          yield
        end
      end

      def bind_on_upload_destroy
        pusher.bind('upload:destroy') do |data|
          @entities_repo.destroy_entity('upload', JSON.parse(data)['id'])
          yield
        end
      end

      def bind_on_itemtype_upsert
        pusher.bind('itemType:upsert') do |data|
          payload = client.item_types.find(JSON.parse(data)['id'], {}, deserialize_response: false)
          @entities_repo.upsert_entities(payload)
          payload = client.items.all({ 'filter[type]' => JSON.parse(data)['id'] },
                                     deserialize_response: false,
                                     all_pages: true)
          @entities_repo.upsert_entities(payload)
          update_items_repo
          yield
        end
      end

      def bind_on_itemtype_destroy
        pusher.bind('itemType:destroy') do |data|
          @entities_repo.destroy_item_type(JSON.parse(data)['id'])
          update_items_repo
          yield
        end
      end

      def update_items_repo
        @items_repo = ItemsRepo.new(@entities_repo)
      end

      def pusher
        PusherClient.logger.level = Logger::WARN
        @pusher ||= PusherClient::Socket.new(PUSHER_API_KEY,
                                             secure: true,
                                             ws_host: 'ws-eu.pusher.com',
                                             auth_method: pusher_auth_method)
      end

      def site
        include = ['item_types', 'item_types.fields']
        client.request(:get, '/site', include: include)
      end

      def all_items
        client.items.all(
          { version: preview_mode ? 'latest' : 'published' },
          deserialize_response: false,
          all_pages: true
        )
      end

      def all_uploads
        client.uploads.all(
          { 'filter[type]' => 'used' },
          deserialize_response: false,
          all_pages: true
        )
      end

      def pusher_auth_method
        proc do |socket_id, channel|
          client.pusher_token(socket_id, channel.name)['auth']
        end
      end
    end
  end
end
