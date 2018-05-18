# frozen_string_literal: true
require 'dato/local/field_type/file'

module Dato
  module Local
    module FieldType
      class Gallery < Array
        def self.parse(value, repo)
          images = if value
                     value.map { |image| FieldType::File.parse(image, repo) }
                   else
                     []
                   end
          new(images)
        end

        def to_hash(max_depth = 3, current_depth = 0)
          map { |item| item.to_hash(max_depth, current_depth) }
        end
      end
    end
  end
end
