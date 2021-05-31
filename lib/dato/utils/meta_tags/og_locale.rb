# frozen_string_literal: true

require "dato/utils/meta_tags/base"

module Dato
  module Utils
    module MetaTags
      class OgLocale < Base
        def build
          locale = I18n.locale
          og_tag("og:locale", "#{locale}_#{locale.upcase}")
        end
      end
    end
  end
end
