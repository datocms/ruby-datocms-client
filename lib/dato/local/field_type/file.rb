# frozen_string_literal: true

require 'imgix'

module Dato
  module Local
    module FieldType
      class File
        def self.parse(value, repo)
          if value
            v = value.with_indifferent_access

            upload = repo.entities_repo.find_entity('upload', v[:upload_id])

            if upload
              new(
                upload,
                v[:alt],
                v[:title],
                v[:custom_data],
                repo.site.entity.imgix_host
              )
            end
          end
        end

        def initialize(
          upload,
          alt,
          title,
          custom_data,
          imgix_host
        )
          @upload = upload
          @alt = alt
          @title = title
          @custom_data = custom_data
          @imgix_host = imgix_host
        end

        def path
          @upload.path
        end

        def format
          @upload.format
        end

        def size
          @upload.size
        end

        def width
          @upload.width
        end

        def height
          @upload.height
        end

        def author
          @upload.author
        end

        def notes
          @upload.notes
        end

        def copyright
          @upload.copyright
        end

        def alt
          default_metadata = @upload.default_field_metadata.deep_stringify_keys.fetch(I18n.locale.to_s, {})
          @alt || default_metadata["alt"]
        end

        def title
          default_metadata = @upload.default_field_metadata.deep_stringify_keys.fetch(I18n.locale.to_s, {})
          @title || default_metadata["title"]
        end

        def custom_data
          default_metadata = @upload.default_field_metadata.deep_stringify_keys.fetch(I18n.locale.to_s, {})
          @custom_data.merge(default_metadata.fetch("custom_data", {}))
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
            width: width,
            height: height,
            alt: alt,
            title: title,
            custom_data: custom_data,
            url: url
          }
        end
      end
    end
  end
end
