# frozen_string_literal: true
module Dato
  module Local
    module FieldType
      class Json
        def self.parse(value, _repo)
          value && JSON.parse(value)
        end
      end
    end
  end
end

