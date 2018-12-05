# frozen_string_literal: true

require 'dato/dump/dsl/directory'
require 'dato/dump/dsl/create_post'
require 'dato/dump/dsl/create_data_file'
require 'dato/dump/dsl/add_to_data_file'

require 'dato/dump/operation/directory'

module Dato
  module Dump
    module Dsl
      class Root
        include Dsl::CreateDataFile
        include Dsl::CreatePost
        include Dsl::AddToDataFile

        attr_reader :dato, :operations

        def initialize(config_code, dato, operations)
          @dato = dato
          @operations = operations

          # rubocop:disable Lint/Eval
          eval(config_code)
          # rubocop:enable Lint/Eval
        end

        def directory(path, &block)
          operation = Operation::Directory.new(operations, path)
          operations.add operation

          Directory.new(dato, operation, &block)
        end
      end
    end
  end
end
