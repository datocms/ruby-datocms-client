# frozen_string_literal: true

require "dato/utils/meta_tags/base"

module Dato
  module Utils
    module MetaTags
      class Description < Base
        def build
          return unless description.present?

          [
            meta_tag("description", description),
            og_tag("og:description", description),
            card_tag("twitter:description", description),
          ]
        end

        def description
          @description ||= seo_field_with_fallback(:description, nil)
        end
      end
    end
  end
end
