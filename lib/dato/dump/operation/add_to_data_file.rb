# frozen_string_literal: true

require "dato/dump/format"

module Dato
  module Dump
    module Operation
      class AddToDataFile
        attr_reader :context, :path, :format, :value

        def initialize(context, path, format, value)
          @context = context
          @path = path
          @format = format
          @value = value
        end

        def perform
          complete_path = File.join(context.path, path)
          FileUtils.mkdir_p(File.dirname(complete_path))

          content_to_add = Format.dump(format, value)

          old_content = if File.exist? complete_path
                          ::File.read(complete_path)
                        else
                          ""
                        end

          new_content = old_content.sub(
            /\n*(#\s*datocms:start.*#\s*datocms:end|\Z)/m,
            "\n\n# datocms:start\n#{content_to_add}\n# datocms:end",
          )

          File.open(complete_path, "w") do |f|
            f.write new_content
          end
        end
      end
    end
  end
end
