# frozen_string_literal: true
module Dato
  module Local
    module FieldType
      class Links < Array
        def self.parse(ids, repo)
          new(ids.map { |id| repo.find(id) })
        end

        def to_hash
          map(&:to_hash)
        end
      end
    end
  end
end
