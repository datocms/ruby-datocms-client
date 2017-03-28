# frozen_string_literal: true
#
module Dato
  module Local
    module FieldType
      class Color
        attr_reader :red, :green, :blue, :alpha

        def self.parse(value, _repo)
          value && new(
            value[:red],
            value[:green],
            value[:blue],
            value[:alpha]
          )
        end

        def initialize(red, green, blue, alpha)
          @red = red
          @green = green
          @blue = blue
          @alpha = alpha / 255.0
        end

        def rgb
          if alpha == 1.0
            "rgb(#{red}, #{green}, #{blue})"
          else #
            "rgba(#{red}, #{green}, #{blue}, #{alpha})"
          end
        end

        def hex
          r = red.to_s(16)
          g = green.to_s(16)
          b = blue.to_s(16)
          a = (alpha * 255).to_i.to_s(16)

          r = "0#{r}" if r.length == 1
          g = "0#{g}" if g.length == 1
          b = "0#{b}" if b.length == 1
          a = "0#{a}" if a.length == 1

          hex = '#' + r + g + b

          hex += a if a != 'ff'

          hex
        end

        def to_hash(*_args)
          {
            red: red,
            green: green,
            blue: blue,
            rgb: rgb,
            hex: hex
          }
        end
      end
    end
  end
end
