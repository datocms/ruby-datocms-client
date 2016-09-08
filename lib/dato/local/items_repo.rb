# frozen_string_literal: true
require 'active_support/core_ext/string'
require 'dato/local/item'
require 'dato/local/site'

module Dato
  module Local
    class ItemsRepo
      attr_reader :entities_repo, :collections_by_type, :item_type_methods

      def initialize(entities_repo)
        @entities_repo = entities_repo
        @collections_by_type = {}
        @items_by_id = {}
        @item_type_methods = {}

        build_cache!
      end

      def find(id)
        @items_by_id[id]
      end

      def respond_to_missing?(method, include_private = false)
        if collections_by_type.key?(method)
          true
        else
          super
        end
      end

      def site
        Site.new(entities_repo.find_entities_of_type('site').first)
      end

      def available_locales
        site.locales.map(&:to_sym)
      end

      def item_types
        entities_repo.find_entities_of_type('item_type')
      end

      def items_of_type(item_type)
        method, singleton = item_type_methods[item_type]

        if singleton
          [@collections_by_type[method]]
        else
          @collections_by_type[method]
        end
      end

      private

      def build_cache!
        build_item_type_methods!
        build_collections_by_type!
      end

      def build_item_type_methods!
        @item_type_methods = {}

        singleton_keys = singleton_item_types.map(&:api_key)
        collection_keys = collection_item_types.map(&:api_key)
                                               .map(&:pluralize)

        clashing_keys = singleton_keys & collection_keys

        item_types.each do |item_type|
          singleton = item_type.singleton
          pluralized_api_key = item_type.api_key.pluralize
          method = singleton ? item_type.api_key : pluralized_api_key

          if clashing_keys.include?(pluralized_api_key)
            suffix = singleton ? 'instance' : 'collection'
            method = "#{method}_#{suffix}"
          end

          @item_type_methods[item_type] = [method.to_sym, singleton]
        end
      end

      def build_collections_by_type!
        item_types.each do |item_type|
          method, singleton = item_type_methods[item_type]

          @collections_by_type[method] = if singleton
                                           nil
                                         else
                                           ItemCollection.new
                                         end
        end

        item_entities.each do |item_entity|
          item = Item.new(item_entity, self)
          method, singleton = item_type_methods[item_entity.item_type]

          if singleton
            @collections_by_type[method] = item
          else
            @collections_by_type[method].push item
          end

          @items_by_id[item.id] = item
        end
      end

      def item_entities
        entities_repo.find_entities_of_type('item')
      end

      def singleton_item_types
        item_types.select(&:singleton)
      end

      def collection_item_types
        item_types - singleton_item_types
      end

      def method_missing(method, *arguments, &block)
        if collections_by_type.key?(method) && arguments.empty?
          collections_by_type[method]
        else
          super
        end
      rescue NoMethodError
        message = []
        message << "Undefined method `#{method}`"
        message << 'Available DatoCMS collections/items:'
        message += collections_by_type.map do |key, _value|
          "* .#{key}"
        end
        raise NoMethodError, message.join("\n")
      end

      class ItemCollection < Array
        def each(&block)
          if block && block.arity == 2
            each_with_object({}) do |item, acc|
              acc[item.id] = item
            end.each(&block)
          else
            super(&block)
          end
        end

        def [](id)
          if id.is_a? String
            find { |item| item.id == id }
          else
            super(id)
          end
        end

        def keys
          map(&:id)
        end

        def values
          to_a
        end
      end
    end
  end
end
