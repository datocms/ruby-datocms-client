# frozen_string_literal: true
require 'imgix'

module Dato
  module Local
    module FieldType
      class File
        attr_reader :path, :format, :size

        def self.parse(value, _repo)
          new(
            value[:path],
            value[:format],
            value[:size]
          )
        end

        def initialize(path, format, size)
          @path = path
          @format = format
          @size = size
        end

        def file(host = default_host)
          Imgix::Client.new(
            host: host,
            secure: true
          ).path(path)
        end

        def url(host: default_host, **opts)
          file(host).to_url(opts)
        end

        def to_hash
          {
            format: format,
            size: size,
            url: url
          }
        end
        
      private
      
        def default_host
          'dato-images.imgix.net'
        end
        
      end
    end
  end
end
