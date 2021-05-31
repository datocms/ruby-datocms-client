# frozen_string_literal: true

require "imgix"

module Dato
  module Local
    module FieldType
      class UploadId
        attr_reader :path, :format, :size, :width, :height

        def self.parse(upload_id, repo)
          if upload_id
            upload = repo.entities_repo.find_entity("upload", upload_id)

            if upload
              new(
                upload.path,
                upload.format,
                upload.size,
                upload.width,
                upload.height,
                repo.site.entity.imgix_host,
              )
            end
          end
        end

        def initialize(
          path,
          format,
          size,
          width,
          height,
          imgix_host
        )
          @path = path
          @format = format
          @size = size
          @imgix_host = imgix_host
          @width = width
          @height = height
        end

        def file
          Imgix::Client.new(
            domain: @imgix_host,
            secure: true,
            include_library_param: false,
          ).path(path)
        end

        def url(opts = {})
          file.to_url(opts)
        end

        def to_hash(*_args)
          {
            format: format,
            size: size,
            width: width,
            height: height,
            url: url,
          }
        end
      end
    end
  end
end
