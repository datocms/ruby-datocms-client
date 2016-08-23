# frozen_string_literal: true
require 'active_support/core_ext/hash/keys'
require 'toml'

module Dato
  module Dump
    module Format
      module Toml
        def self.dump(value)
          TOML::Generator.new(value).body
        end

        def self.frontmatter_dump(value)
          "+++\n#{dump(value)}+++"
        end
      end
    end
  end
end
