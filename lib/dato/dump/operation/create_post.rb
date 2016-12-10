# frozen_string_literal: true
require 'fileutils'
require 'dato/dump/format'

module Dato
  module Dump
    module Operation
      class CreatePost
        attr_reader :context, :path

        attr_accessor :frontmatter_format, :frontmatter_value
        attr_accessor :content

        def initialize(context, path)
          @context = context
          @path = path
        end

        def perform
          FileUtils.mkdir_p(File.dirname(path))

          File.open(File.join(context.path, path), 'w') do |file|
            file.write Format.frontmatter_dump(
              frontmatter_format,
              frontmatter_value
            )
            file.write "\n\n"
            file.write content
          end
        end
      end
    end
  end
end
