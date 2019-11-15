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

        def id
          @upload.id
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

        def filename
          @upload.filename
        end

        def basename
          @upload.basename
        end

        def alt
          default_metadata = @upload.default_field_metadata.deep_stringify_keys
                                    .fetch(I18n.locale.to_s, {})
          @alt || default_metadata['alt']
        end

        def title
          default_metadata = @upload.default_field_metadata.deep_stringify_keys
                                    .fetch(I18n.locale.to_s, {})
          @title || default_metadata['title']
        end

        def custom_data
          default_metadata = @upload.default_field_metadata.deep_stringify_keys
                                    .fetch(I18n.locale.to_s, {})
          @custom_data.merge(default_metadata.fetch('custom_data', {}))
        end

        def tags
          @upload.tags
        end

        def smart_tags
          @upload.smart_tags
        end

        def is_image
          @upload.is_image
        end

        def exif_info
          @upload.exif_info
        end

        def mime_type
          @upload.mime_type
        end

        def colors
          @upload.colors.map do |hex|
            r, g, b = (hex[0] == '#' ? hex[1..7] : hex).scan(/../).map do |v|
              begin
                Integer(v, 16)
              rescue StandardError
                raise 'Invalid hexcolor.'
              end
            end
            Color.new(r, g, b, 255)
          end
        end

        def blurhash
          @upload.blurhash
        end

        def mux_resolutions
          # mux_mp4_highest_res
          resolutions = %w[low medium high]
          max = resolutions.index(@upload.mux_mp4_highest_res)
          resolutions[0..max].each_with_object({}) do |res, acc|
            acc["mp4_#{res}_res_url"] =
              "https://stream.mux.com/#{@upload.mux_playback_id}/#{res}.mp4"
          end
        end

        def video
          if @upload.mux_playback_id
            {
              mux_playback_id: @upload.mux_playback_id,
              mux_asset_status: @upload.mux_asset_status,
              framerate: @upload.frame_rate,
              duration: @upload.duration,
              gif_url: "https://image.mux.com/#{@upload.mux_playback_id}/animated.gif",
              hls_url: "https://stream.mux.com/#{@upload.mux_playback_id}.m3u8",
              thumbnail_url: "https://image.mux.com/#{@upload.mux_playback_id}/thumbnail.jpg"
            }.merge(mux_resolutions).with_indifferent_access
          end
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
            id: id,
            format: format,
            size: size,
            width: width,
            height: height,
            alt: alt,
            title: title,
            custom_data: custom_data,
            url: url,
            copyright: copyright,
            tags: tags,
            smart_tags: smart_tags,
            filename: filename,
            basename: basename,
            is_image: is_image,
            exif_info: exif_info,
            mime_type: mime_type,
            colors: colors.map(&:to_hash),
            blurhash: blurhash,
            video: video
          }
        end
      end
    end
  end
end
