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
        @items_by_parent_id = {}
        @item_type_methods = {}

        build_cache!
      end

      def find(id)
        @items_by_id[id.to_s]
      end

      def children_of(id)
        @items_by_parent_id[id.to_s]
      end

      def respond_to_missing?(method, include_private = false)
        if collections_by_type.key?(method)
          true
        else
          super
        end
      end

      def site
        Site.new(
          entities_repo.find_entities_of_type('site').first,
          self
        )
      end

      def available_locales
        site.locales.map(&:to_sym)
      end

      def item_types
        entities_repo.find_entities_of_type('item_type')
      end

      def single_instance_item_types
        item_types.select(&:singleton)
      end

      def collection_item_types
        item_types - single_instance_item_types
      end

      def items_of_type(item_type)
        method = item_type_methods[item_type]

        if item_type.singleton
          Array(@collections_by_type[method])
        else
          @collections_by_type[method]
        end
      end

      private

      def build_cache!
        build_item_type_methods!
        build_collections_by_type!
        build_singletons_by_type!
      end

      def build_item_type_methods!
        @item_type_methods = {}

        singleton_keys = single_instance_item_types.map(&:api_key)
        collection_keys = collection_item_types.map(&:api_key)
                                               .map(&:pluralize)

        clashing_keys = singleton_keys & collection_keys

        item_types.each do |item_type|
          pluralized_api_key = item_type.api_key.pluralize

          method = if item_type.singleton
                     item_type.api_key
                   else
                     pluralized_api_key
                   end

          if clashing_keys.include?(pluralized_api_key)
            suffix = item_type.singleton ? 'instance' : 'collection'
            method = "#{method}_#{suffix}"
          end

          @item_type_methods[item_type] = method.to_sym
        end
      end

      def build_collections_by_type!
        item_types.each do |item_type|
          method = item_type_methods[item_type]
          @collections_by_type[method] = if item_type.singleton
                                           nil
                                         else
                                           ItemCollection.new
                                         end
        end

        item_entities.each do |item_entity|
          item = Item.new(item_entity, self)
          method = item_type_methods[item_entity.item_type]

          unless item_entity.item_type.singleton
            @collections_by_type[method].push item
          end

          @items_by_id[item.id] = item

          if item_entity.respond_to?(:parent_id) && item_entity.parent_id
            @items_by_parent_id[item_entity.parent_id] ||= []
            @items_by_parent_id[item_entity.parent_id] << item
          end
        end

        item_types.each do |item_type|
          method = item_type_methods[item_type]
          if !item_type.singleton && item_type.sortable
            @collections_by_type[method].sort_by!(&:position)
          end
        end
      end

      def build_singletons_by_type!
        item_types.each do |item_type|
          method = item_type_methods[item_type]
          next unless item_type.singleton

          item = if item_type.singleton_item
                   @items_by_id[item_type.singleton_item.id]
                 end

          @collections_by_type[method] = item
        end
      end

      def item_entities
        entities_repo.find_entities_of_type('item')
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
