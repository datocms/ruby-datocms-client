# frozen_string_literal: true

require 'forwardable'
require 'active_support/inflector/transliterate'
require 'active_support/hash_with_indifferent_access'
require 'dato/utils/locale_value'

Dir[File.dirname(__FILE__) + '/field_type/*.rb'].each do |file|
  require file
end

module Dato
  module Local
    class Item
      extend Forwardable

      attr_reader :entity
      def_delegators :entity, :id, :meta

      def initialize(entity, items_repo)
        @entity = entity
        @items_repo = items_repo
      end

      def ==(other)
        other.is_a?(Item) && other.id == id
      end

      def seo_meta_tags
        Utils::SeoTagsBuilder.new(self, @items_repo.site).meta_tags
      end

      def singleton?
        item_type.singleton
      end
      alias single_instance? singleton?

      def item_type
        @item_type ||= entity.item_type
      end

      def fields
        @fields ||= item_type.fields.sort_by(&:position)
      end

      def attributes
        fields.each_with_object(
          ActiveSupport::HashWithIndifferentAccess.new
        ) do |field, acc|
          acc[field.api_key.to_sym] = send(field.api_key)
        end
      end

      def position
        entity.position
      end

      def parent
        @items_repo.find(entity.parent_id) if item_type.tree && entity.parent_id
      end

      def children
        @items_repo.children_of(id).sort_by(&:position) if item_type.tree
      end

      def updated_at
        Time.parse(meta.updated_at).utc
      end

      def created_at
        Time.parse(meta.created_at).utc
      end

      def to_s
        api_key = item_type.api_key
        "#<Item id=#{id} item_type=#{api_key} attributes=#{attributes}>"
      end
      alias inspect to_s

      def to_hash(max_depth = 3, current_depth = 0)
        return id if current_depth >= max_depth

        base = {
          id: id,
          item_type: item_type.api_key,
          updated_at: updated_at,
          created_at: created_at
        }

        base[:position] = position if item_type.sortable

        if item_type.tree
          base[:position] = position
          base[:children] = children.map do |child|
            child.to_hash(
              max_depth,
              current_depth + 1
            )
          end
        end

        fields.each_with_object(base) do |field, result|
          value = send(field.api_key)

          result[field.api_key.to_sym] = if value.respond_to?(:to_hash)
                                           value.to_hash(
                                             max_depth,
                                             current_depth + 1
                                           )
                                         else
                                           value
                                         end
        end
      end

      private

      def read_attribute(method, field)
        field_type = field.field_type
        type_klass_name = "::Dato::Local::FieldType::#{field_type.camelize}"
        type_klass = type_klass_name.safe_constantize

        value = if field.localized
                  obj = entity.send(method) || {}
                  Utils::LocaleValue.find(obj)
                else
                  entity.send(method)
                end

        if type_klass
          type_klass.parse(value, @items_repo)
        else
          warning = [
            "Warning: unrecognized field of type `#{field_type}`",
            "for item `#{item_type.api_key}` and",
            "field `#{method}`: returning a simple Hash instead.",
            'Please upgrade to the latest version of the `dato` gem!'
          ]
          puts warning.join(' ')

          value
        end
      end

      def method_missing(method, *arguments, &block)
        field = fields.find { |f| f.api_key.to_sym == method }
        if field && arguments.empty?
          read_attribute(method, field)
        else
          super
        end
      rescue NoMethodError => e
        if e.name === method
          message = []
          message << "Undefined method `#{method}`"
          message << "Available fields for a `#{item_type.api_key}` item:"
          message += fields.map do |f|
            "* .#{f.api_key}"
          end
          raise NoMethodError, message.join("\n")
        else
          raise e
        end
      end

      def respond_to_missing?(method, include_private = false)
        field = fields.find { |f| f.api_key.to_sym == method }
        if field
          true
        else
          super
        end
      end
    end
  end
end
