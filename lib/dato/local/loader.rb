# frozen_string_literal: true

require 'pusher-client'

require 'dato/local/entities_repo'
require 'dato/local/items_repo'

module Dato
  module Local
    class Loader
      attr_reader :client
      attr_reader :entities_repo
      attr_reader :items_repo
      attr_reader :preview_mode

      PUSHER_API_KEY = '75e6ef0fe5d39f481626'

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

      def watch(&block)
        site_id = client.get('/site')['data']['id']

        return if pusher && pusher.connected

        channel_name = if client.environment
                         "private-site-#{site_id}-environment-#{environment}"
                       else
                         "private-site-#{site_id}"
                       end

        pusher.subscribe(channel_name)

        bind_on_site_upsert(&block)
        bind_on_item_destroy(&block)
        bind_on_item_upsert(&block)
        bind_on_item_type_upsert(&block)
        bind_on_item_type_destroy(&block)
        bind_on_upload_upsert(&block)
        bind_on_upload_destroy(&block)

        pusher.connect(true)
      end

      def stop_watch
        pusher.disconnect if pusher && pusher.connected
      end

      private

      def bind_on_site_upsert(&block)
        bind_on("site:upsert", block) do |data|
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
        end
      end

      def bind_on_item_upsert(&block)
        event_type = preview_mode ? 'preview_mode' : 'published_mode'

        bind_on("item:#{event_type}:upsert", block) do |data|
          payload = client.items.all(
            {
              'filter[ids]' => data[:ids].join(','),
              version: item_version
            },
            deserialize_response: false,
            all_pages: true
          )

          @entities_repo.upsert_entities(payload)
        end
      end

      def bind_on_item_destroy(&block)
        event_type = preview_mode ? 'preview_mode' : 'published_mode'

        bind_on("item:#{event_type}:destroy", block) do |data|
          @entities_repo.destroy_entities('item', data[:ids])
        end
      end

      def bind_on_upload_upsert(&block)
        bind_on("upload:upsert", block) do |data|
          payload = client.uploads.all(
            {
              'filter[ids]' => data[:ids].join(',')
            },
            deserialize_response: false,
            all_pages: true
          )

          @entities_repo.upsert_entities(payload)
        end
      end

      def bind_on_upload_destroy(&block)
        bind_on('upload:destroy', block) do |data|
          @entities_repo.destroy_entities('upload', data[:ids])
        end
      end

      def bind_on_item_type_upsert(&block)
        bind_on('item_type:upsert', block) do |data|
          data[:ids].each do |id|
            payload = client.item_types.find(id, {}, deserialize_response: false)
            @entities_repo.upsert_entities(payload)

            payload = client.items.all(
              { 'filter[type]' => id },
              deserialize_response: false,
              all_pages: true
            )

            @entities_repo.upsert_entities(payload)
          end
        end
      end

      def bind_on_item_type_destroy(&block)
        bind_on('item_type:destroy', block) do |data|
          data[:ids].each do |id|
            @entities_repo.destroy_item_type(id)
          end
        end
      end

      def bind_on(event_name, user_block, &block)
        pusher.bind(event_name) do |data|
          parsed_data = JSON.parse(data)
          block.call(parsed_data.deep_symbolize_keys)
          update_items_repo!
          user_block.call
        end
      end

      def update_items_repo!
        @items_repo = ItemsRepo.new(@entities_repo)
      end

      def pusher
        PusherClient.logger.level = Logger::WARN

        @pusher ||= PusherClient::Socket.new(
          PUSHER_API_KEY,
          secure: true,
          auth_method: method(:pusher_auth_method)
        )
      end

      def site
        client.get('/site', include: ['item_types', 'item_types.fields'])
      end

      def all_items
        client.items.all(
          { version: item_version },
          deserialize_response: false,
          all_pages: true
        )
      end

      def all_uploads
        client.uploads.all({},
                           deserialize_response: false,
                           all_pages: true)
      end

      def item_version
        if preview_mode
          'latest'
        else
          'published'
        end
      end

      def pusher_auth_method(socket_id, channel)
        client.pusher_token(socket_id, channel.name)["auth"]
      end
    end
  end
end
