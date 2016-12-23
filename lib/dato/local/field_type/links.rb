# frozen_string_literal: true
module Dato
  module Local
    module FieldType
      class Links < Array
        def self.parse(ids, repo)
          items = if ids
                    ids.map { |id| repo.find(id) }
                  else
                    []
                  end
          new(items)
        end

        def to_hash
          map(&:to_hash)
        end
      end
    end
  end
end
