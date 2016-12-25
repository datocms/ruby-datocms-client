# frozen_string_literal: true
require 'dato/local/entities_repo'
require 'dato/local/items_repo'

module Dato
  module Local
    class Loader
      attr_reader :client
      attr_reader :entities_repo
      attr_reader :items_repo

      def initialize(client)
        @client = client
        @entities_repo = EntitiesRepo.new
        @items_repo = ItemsRepo.new(@entities_repo)
      end

      def load
        @entities_repo = EntitiesRepo.new(site, all_items)
        @items_repo = ItemsRepo.new(@entities_repo)
      end

      private

      def site
        include = [
          'item_types',
          'item_types.fields'
        ]
        client.request(:get, '/site', include: include)
      end

      def all_items
        client.items.all({}, false)
      end
    end
  end
end
