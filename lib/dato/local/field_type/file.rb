# frozen_string_literal: true
require 'imgix'

module Dato
  module Local
    module FieldType
      class File
        attr_reader :path, :format, :size

        def self.parse(value, repo)
          value && new(
            value[:path],
            value[:format],
            value[:size],
            repo.site.entity.imgix_host
          )
        end

        def initialize(path, format, size, imgix_host)
          @path = path
          @format = format
          @size = size
          @imgix_host = imgix_host
        end

        def file
          Imgix::Client.new(
            host: @imgix_host,
            secure: true,
            include_library_param: false
          ).path(path)
        end

        def url(opts = {})
          file.to_url(opts)
        end

        def to_hash(*_args)
          {
            format: format,
            size: size,
            url: url
          }
        end
      end
    end
  end
end
