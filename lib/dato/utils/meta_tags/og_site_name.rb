# frozen_string_literal: true

require 'dato/utils/meta_tags/base'

module Dato
  module Utils
    module MetaTags
      class OgSiteName < Base
        def build
          og_tag('og:site_name', site_name) if site_name
        end

        def site_name
          site.global_seo && site.global_seo.site_name
        end
      end
    end
  end
end
