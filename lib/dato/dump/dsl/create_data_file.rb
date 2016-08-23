# frozen_string_literal: true
require 'dato/dump/operation/create_data_file'

module Dato
  module Dump
    module Dsl
      module CreateDataFile
        def create_data_file(*args)
          operations.add Operation::CreateDataFile.new(operations, *args)
        end
      end
    end
  end
end
