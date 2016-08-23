# frozen_string_literal: true
require 'active_support/core_ext/hash/keys'
require 'yaml'

module Dato
  module Dump
    module Format
      module Yaml
        def self.dump(value)
          YAML.dump(value).chomp.gsub(/^\-+\n/, '')
        end

        def self.frontmatter_dump(value)
          "---\n#{dump(value)}\n---"
        end
      end
    end
  end
end
