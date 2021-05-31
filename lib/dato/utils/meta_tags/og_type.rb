# frozen_string_literal: true

require "dato/utils/meta_tags/base"

module Dato
  module Utils
    module MetaTags
      class OgType < Base
        def build
          if !item || item.singleton?
            og_tag("og:type", "website")
          else
            og_tag("og:type", "article")
          end
        end
      end
    end
  end
end
