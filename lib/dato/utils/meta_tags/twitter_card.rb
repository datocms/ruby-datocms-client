# frozen_string_literal: true

require "dato/utils/meta_tags/base"

module Dato
  module Utils
    module MetaTags
      class TwitterCard < Base
        def build
          card_tag("twitter:card", seo_field_with_fallback(:twitter_card, nil) || "summary")
        end
      end
    end
  end
end
