# frozen_string_literal: true

require "yaml"

class Array
  def deep_stringify_keys
    each_with_object([]) do |value, accum|
      if value.is_a?(Hash) || value.is_a?(Array)
        new_val = value.deep_stringify_keys
        accum.push new_val
      else
        accum.push value
      end
      accum
    end
  end
end

module Dato
  module Dump
    module Format
      module Yaml
        def self.dump(value)
          YAML.dump(value.deep_stringify_keys).chomp.gsub(/^-+\n/, "")
        end

        def self.frontmatter_dump(value)
          "---\n#{dump(value)}\n---"
        end
      end
    end
  end
end
