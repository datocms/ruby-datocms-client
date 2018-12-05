# frozen_string_literal: true

module Dato
  module Local
    module FieldType
      class RichText < Array
        def self.parse(ids, repo)
          items = if ids
                    ids.map { |id| repo.find(id) }
                  else
                    []
                  end
          new(items)
        end

        def to_hash(max_depth = 3, current_depth = 0)
          map { |item| item.to_hash(max_depth, current_depth) }
        end
      end
    end
  end
end
