# frozen_string_literal: true
module Dato
  module Local
    module FieldType
      class DateTime
        def self.parse(value, _repo)
          value && ::Time.parse(value).utc
        end
      end
    end
  end
end
