# frozen_string_literal: true
require 'fastimage'

module Dato
  module Upload
    class Image < File
      IMAGE_FORMATS = %w[png jpg jpeg gif].freeze

      def format_resource(upload_request)
        extension = FastImage.type(file.path).to_s
        if IMAGE_FORMATS.include?(extension)
          width, height = FastImage.size(file.path)
          base_format = {
            path: upload_request[:id],
            size: ::File.size(file.path),
            width: width,
            height: height,
            format: extension,
            size: ::File.size(file.path)
          }
          base_format
        else
          raise FastImage::UnknownImageType
        end
      end
    end
  end
end
