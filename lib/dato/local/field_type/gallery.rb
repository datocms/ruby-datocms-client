# frozen_string_literal: true
require 'dato/local/field_type/file'

module Dato
  module Local
    module FieldType
      class Gallery < Array
        def self.parse(value, repo)
          images = if value
                     value.map { |image| FieldType::Image.parse(image, repo) }
                   else
                     []
                   end
          new(images)
        end

        def to_hash
          map(&:to_hash)
        end
      end
    end
  end
end
