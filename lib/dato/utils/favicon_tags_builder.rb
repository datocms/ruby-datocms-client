# frozen_string_literal: true

module Dato
  module Utils
    class FaviconTagsBuilder
      attr_reader :theme_color, :site

      APPLE_TOUCH_ICON_SIZES = [57, 60, 72, 76, 114, 120, 144, 152, 180].freeze
      ICON_SIZES = [16, 32, 96, 192].freeze
      WINDOWS_SIZES = [[70, 70], [150, 150], [310, 310], [310, 150]].freeze

      def initialize(site, theme_color)
        @site = site
        @theme_color = theme_color
      end

      def meta_tags
        [
          build_icon_tags,
          build_apple_icon_tags,
          build_windows_tags,
          build_color_tags,
          build_app_name_tag,
        ].flatten.compact
      end

      def build_apple_icon_tags
        return unless site.favicon

        APPLE_TOUCH_ICON_SIZES.map do |size|
          link_tag(
            "apple-touch-icon",
            url(size),
            sizes: "#{size}x#{size}",
          )
        end
      end

      def build_icon_tags
        return unless site.favicon

        ICON_SIZES.map do |size|
          link_tag(
            "icon",
            url(size),
            sizes: "#{size}x#{size}",
            type: "image/#{site.favicon.format}",
          )
        end
      end

      def build_windows_tags
        return unless site.favicon

        WINDOWS_SIZES.map do |(w, h)|
          meta_tag("msapplication-square#{w}x#{h}logo", url(w, h))
        end
      end

      def build_app_name_tag
        meta_tag("application-name", site.name)
      end

      def build_color_tags
        return unless theme_color

        [
          meta_tag("theme-color", theme_color),
          meta_tag("msapplication-TileColor", theme_color),
        ]
      end

      def url(width, height = width)
        site.favicon.url(w: width, h: height)
      end

      def meta_tag(name, value)
        { tag_name: "meta", attributes: { name: name, content: value } }
      end

      def link_tag(rel, href, attrs = {})
        { tag_name: "link", attributes: attrs.merge(rel: rel, href: href) }
      end
    end
  end
end
