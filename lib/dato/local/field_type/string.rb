# frozen_string_literal: true
module Dato
  module Local
    module FieldType
      class String
        def self.parse(value, _repo)
          value
        end
      end
    end
  end
end
