# frozen_string_literal: true

require 'dato/utils/meta_tags/base'

module Dato
  module Utils
    module MetaTags
      class ArticlePublisher < Base
        def build
          og_tag('article:publisher', facebook_page_url) if facebook_page_url
        end

        def facebook_page_url
          site.global_seo && site.global_seo.facebook_page_url
        end
      end
    end
  end
end
