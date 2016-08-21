require "dato/upload/file"
require "fastimage"

module Dato
  module Upload
    class Image < Dato::Upload::File
      def format_resource(upload_request)
        width, height = FastImage.size(file.path)

        super(upload_request).merge(
          width: width,
          height: height,
          format: FastImage.type(file.path).to_s
        )
      end
    end
  end
end

