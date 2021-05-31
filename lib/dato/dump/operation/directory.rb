# frozen_string_literal: true

require "fileutils"

module Dato
  module Dump
    module Operation
      class Directory
        attr_reader :context, :path

        def initialize(context, path)
          @context = context
          @path = File.join(context.path, path)
          @operations = []
        end

        def add(operation)
          @operations << operation
        end

        def perform
          FileUtils.remove_dir(path) if Dir.exist?(path)

          FileUtils.mkdir_p(path)

          operations.each(&:perform)
        end

        private

        attr_reader :operations
      end
    end
  end
end
