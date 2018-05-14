# frozen_string_literal: true
module Dato
  module Local
    module FieldType
      class Seo
        attr_reader :title, :description

        def self.parse(value, repo)
          value && new(value[:title], value[:description], value[:image], repo)
        end

        def initialize(title, description, image, repo)
          @title = title
          @description = description
          @image = image
          @repo = repo
        end

        def image
          @image && File.parse(@image, @repo)
        end

        def to_hash(*args)
          {
            title: title,
            description: description,
            image: image && image.to_hash(*args)
          }
        end
      end
    end
  end
end
