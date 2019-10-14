# frozen_string_literal: true

require 'dato/upload/create_upload_path'

module Dato
  module Upload
    class File
      attr_reader :client, :source, :upload_attributes, :field_attributes

      def initialize(client, source, upload_attributes = {}, field_attributes = {})
        @client = client
        @source = source
        @upload_attributes = upload_attributes
        @field_attributes = field_attributes
      end

      def upload
        upload_path = CreateUploadPath.new(client, source).upload_path

        upload = client.uploads.create(
          upload_attributes.merge(path: upload_path)
        )

        {
          alt: nil,
          title: nil,
          custom_data: {},
        }.merge(field_attributes).merge(upload_id: upload['id'])
      end
    end
  end
end
