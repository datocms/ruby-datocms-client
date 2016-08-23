# frozen_string_literal: true
require 'dato/dump/operation/create_post'

module Dato
  module Dump
    module Dsl
      class DataFile
        def initialize(operation, &block)
          @operation = operation
          instance_eval(&block)
        end

        def frontmatter(format, value)
          @operation.frontmatter_format = format
          @operation.frontmatter_value = value
        end

        def content(value)
          @operation.content = value
        end
      end

      module CreatePost
        def create_post(path, &block)
          operation = Operation::CreatePost.new(operations, path)
          DataFile.new(operation, &block)

          operations.add operation
        end
      end
    end
  end
end
