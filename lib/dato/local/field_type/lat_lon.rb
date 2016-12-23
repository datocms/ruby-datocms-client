# frozen_string_literal: true
module Dato
  module Local
    module FieldType
      class LatLon
        attr_reader :latitude, :longitude

        def self.parse(value, _repo)
          value && new(value[:latitude], value[:longitude])
        end

        def initialize(latitude, longitude)
          @latitude = latitude
          @longitude = longitude
        end

        def values
          [latitude, longitude]
        end

        def to_hash
          {
            latitude: latitude,
            longitude: longitude
          }
        end
      end
    end
  end
end
