# frozen_string_literal: true
require 'dato/dump/dsl/create_post'
require 'dato/dump/dsl/create_data_file'
require 'dato/dump/dsl/add_to_data_file'

module Dato
  module Dump
    module Dsl
      class Directory
        include Dsl::CreateDataFile
        include Dsl::CreatePost
        include Dsl::AddToDataFile

        attr_reader :dato, :operations

        def initialize(dato, operations, &block)
          @dato = dato
          @operations = operations

          instance_eval(&block)
        end
      end
    end
  end
end
