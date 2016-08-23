# frozen_string_literal: true
module Dato
  module Dump
    module Operation
      class Root
        attr_reader :path

        def initialize(path)
          @operations = []
          @path = path
        end

        def add(operation)
          @operations << operation
        end

        def perform
          operations.each(&:perform)
        end

        private

        attr_reader :operations
      end
    end
  end
end
