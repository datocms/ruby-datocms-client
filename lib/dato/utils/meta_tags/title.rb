# frozen_string_literal: true
require 'dato/utils/meta_tags/base'

module Dato
  module Utils
    module MetaTags
      class Title < Base
        def build
          return unless item_title

          [
            content_tag(:title, item_title_with_suffix),
            og_tag('og:title', item_title),
            card_tag('twitter:title', item_title)
          ]
        end

        def title_field
          item && item.fields.find do |field|
            field.field_type == 'string' &&
              field.appeareance[:type] == 'title'
          end
        end

        def item_title
          @item_title ||= seo_field_with_fallback(
            :title,
            title_field && item.send(title_field.api_key)
          )
        end

        def suffix
          (site.global_seo && site.global_seo.title_suffix) || ''
        end

        def item_title_with_suffix
          if (item_title + suffix).size <= 60
            item_title + suffix
          else
            item_title
          end
        end
      end
    end
  end
end
