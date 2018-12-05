# frozen_string_literal: true

require 'dato/dump/format/toml'
require 'dato/dump/format/yaml'

module Dato
  module Dump
    module Format
      def self.dump(format, value)
        converter_for(format).dump(value)
      end

      def self.frontmatter_dump(format, value)
        converter_for(format).frontmatter_dump(value)
      end

      def self.converter_for(format)
        case format.to_sym
        when :toml
          Format::Toml
        when :yaml, :yml
          Format::Yaml
        when :json
          Format::Json
        end
      end
    end
  end
end
