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
        items_per_page = 500
        base_response = client.request(:get, '/items', 'page[limit]' => 1)

        pages = (base_response[:meta][:total_count] / items_per_page.to_f).ceil
        base_response[:data] = []

        pages.times do |page|
          base_response[:data] += client.request(
            :get,
            '/items',
            'page[offset]' => items_per_page * page,
            'page[limit]' => items_per_page
          )[:data]
        end

        base_response
      end
    end
  end
end
