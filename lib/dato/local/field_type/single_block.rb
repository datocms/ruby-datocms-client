# frozen_string_literal: true

module Dato
  module Local
    module FieldType
      class SingleBlock
        def self.parse(value, repo)
          value && repo.find(value)
        end
      end
    end
  end
end
