# frozen_string_literal: true
require 'forwardable'
require 'active_support/inflector/transliterate'
require 'active_support/hash_with_indifferent_access'

module Dato
  module Local
    class Site
      extend Forwardable

      attr_reader :entity
      def_delegators :entity, :id, :name, :locales, :theme_hue, :domain,
                     :internal_domain, :no_index

      def initialize(entity)
        @entity = entity
      end

      def global_seo
        read_attribute(:global_seo, FieldType::GlobalSeo, locales.size > 1)
      end

      def favicon
        read_attribute(:favicon, FieldType::Image, false)
      end

      def to_s
        "#<Site id=#{id} site_name=#{name}>"
      end
      alias inspect to_s

      def favicon_meta_tags(theme_color = nil)
        Utils::FaviconTagsBuilder.new(self, theme_color).meta_tags
      end

      def to_hash
        attributes = [
          :id, :name, :locales, :theme_hue, :domain, :internal_domain,
          :no_index, :global_seo, :favicon
        ]

        attributes.each_with_object({}) do |attribute, result|
          value = send(attribute)
          result[attribute] = if value.respond_to?(:to_hash)
                                value.to_hash
                              else
                                value
                              end
        end
      end

      private

      def read_attribute(method, type_klass, localized)
        value = if localized
                  (entity.send(method) || {})[I18n.locale]
                else
                  entity.send(method)
                end

        value && type_klass.parse(value, @items_repo)
      end
    end
  end
end
