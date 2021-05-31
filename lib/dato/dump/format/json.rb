# frozen_string_literal: true

require "json"

module Dato
  module Dump
    module Format
      module Json
        def self.dump(value)
          JSON.dump(value)
        end

        def self.frontmatter_dump(value)
          "#{dump(value)}\n"
        end
      end
    end
  end
end
