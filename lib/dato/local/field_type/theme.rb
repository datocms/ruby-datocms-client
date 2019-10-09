# frozen_string_literal: true

module Dato
  module Local
    module FieldType
      class Theme
        attr_reader :primary_color, :dark_color, :light_color, :accent_color

        def self.parse(value, repo)
          value && new(
            value[:logo],
            value[:primary_color],
            value[:dark_color],
            value[:light_color],
            value[:accent_color],
            repo
          )
        end

        def initialize(logo, primary_color, dark_color, light_color, accent_color, repo)
          @logo = logo
          @primary_color = primary_color
          @dark_color = dark_color
          @light_color = light_color
          @accent_color = accent_color
          @repo = repo
        end

        def logo
          @logo && UploadId.parse(@logo, @repo)
        end

        def to_hash(*args)
          {
            primary_color: primary_color,
            dark_color: dark_color,
            light_color: light_color,
            accent_color: accent_color,
            logo: logo && logo.to_hash(*args)
          }
        end
      end
    end
  end
end
