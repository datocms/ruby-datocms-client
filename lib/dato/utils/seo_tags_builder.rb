# frozen_string_literal: true
require 'dato/utils/meta_tags/title'
require 'dato/utils/meta_tags/description'
require 'dato/utils/meta_tags/image'
require 'dato/utils/meta_tags/robots'
require 'dato/utils/meta_tags/og_locale'
require 'dato/utils/meta_tags/og_type'
require 'dato/utils/meta_tags/og_site_name'
require 'dato/utils/meta_tags/article_modified_time'
require 'dato/utils/meta_tags/article_publisher'
require 'dato/utils/meta_tags/twitter_card'
require 'dato/utils/meta_tags/twitter_site'

module Dato
  module Utils
    class SeoTagsBuilder
      META_TAGS = [
        MetaTags::Title,
        MetaTags::Description,
        MetaTags::Image,
        MetaTags::Robots,
        MetaTags::OgLocale,
        MetaTags::OgType,
        MetaTags::OgSiteName,
        MetaTags::ArticleModifiedTime,
        MetaTags::ArticlePublisher,
        MetaTags::TwitterCard,
        MetaTags::TwitterSite
      ].freeze

      attr_reader :site, :item

      def initialize(item, site)
        @item = item
        @site = site
      end

      def meta_tags
        META_TAGS.map do |klass|
          klass.new(item, site).build
        end.flatten.compact
      end
    end
  end
end
