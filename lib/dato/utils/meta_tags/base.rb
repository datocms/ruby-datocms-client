# frozen_string_literal: true
require 'forwardable'
require 'dato/local/field_type/seo'
require 'active_support/core_ext/object/blank'

module Dato
  module Utils
    module MetaTags
      class Base
        attr_reader :site, :item

        def initialize(item, site)
          @item = item
          @site = site
        end

        def seo_field_with_fallback(attribute, alternative)
          fallback_seo = site.global_seo && site.global_seo.fallback_seo

          seo_field = item &&
                      item.fields.detect { |f| f.field_type == 'seo' }

          item_seo_value = seo_field &&
                           item.send(seo_field.api_key) &&
                           item.send(seo_field.api_key).send(attribute)

          fallback_seo_value = fallback_seo &&
                               fallback_seo.send(attribute)

          item_seo_value || alternative || fallback_seo_value
        end

        def tag(tag_name, attributes)
          { tag_name: tag_name, attributes: attributes }
        end

        def meta_tag(name, content)
          tag('meta', name: name, content: content)
        end

        def og_tag(property, content)
          tag('meta', property: property, content: content)
        end

        def card_tag(name, content)
          meta_tag(name, content)
        end

        def content_tag(tag_name, content)
          { tag_name: tag_name, content: content }
        end
      end
    end
  end
end
