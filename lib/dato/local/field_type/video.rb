# frozen_string_literal: true
require 'active_support/core_ext/hash/compact'
require 'video_embed'

module Dato
  module Local
    module FieldType
      class Video
        attr_reader :url
        attr_reader :thumbnail_url
        attr_reader :title
        attr_reader :width
        attr_reader :height
        attr_reader :provider
        attr_reader :provider_url
        attr_reader :provider_uid

        def self.parse(value, _repo)
          value && new(
            value[:url],
            value[:thumbnail_url],
            value[:title],
            value[:width],
            value[:height],
            value[:provider],
            value[:provider_url],
            value[:provider_uid]
          )
        end

        def initialize(
          url,
          thumbnail_url,
          title,
          width,
          height,
          provider,
          provider_url,
          provider_uid
        )
          @url            = url
          @thumbnail_url  = thumbnail_url
          @title          = title
          @width          = width
          @height         = height
          @provider       = provider
          @provider_url   = provider_url
          @provider_uid   = provider_uid
        end

        def iframe_embed(width = nil, height = nil)
          VideoEmbed.embed(url, { width: width, height: height }.compact)
        end

        def to_hash
          {
            url: url,
            thumbnail_url: thumbnail_url,
            title: title,
            width: width,
            height: height,
            provider: provider,
            provider_url: provider_url,
            provider_uid: provider_uid
          }
        end
      end
    end
  end
end
