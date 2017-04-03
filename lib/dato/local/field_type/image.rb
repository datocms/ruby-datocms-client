# frozen_string_literal: true
require 'dato/local/field_type/file'

module Dato
  module Local
    module FieldType
      class Image < Dato::Local::FieldType::File
        attr_reader :width, :height, :title, :alt

        def self.parse(value, _repo)
          value && new(
            value[:path],
            value[:format],
            value[:size],
            value[:width],
            value[:height],
            value[:alt],
            value[:title]
          )
        end

        def initialize(path, format, size, width, height, alt, title)
          super(path, format, size)
          @width = width
          @height = height
          @alt = alt
          @title = title
        end

        def to_hash(*args)
          super.merge(
            width: width,
            height: height,
            alt: alt,
            title: title
          )
        end
      end
    end
  end
end
