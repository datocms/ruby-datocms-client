# frozen_string_literal: true

require "dato/utils/meta_tags/base"

module Dato
  module Utils
    module MetaTags
      class Robots < Base
        def build
          meta_tag("robots", "noindex") if site.no_index
        end
      end
    end
  end
end
