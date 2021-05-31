# frozen_string_literal: true

module Dato
  module Local
    module FieldType
      class Video
        attr_reader :url, :thumbnail_url, :title, :width, :height, :provider, :provider_url, :provider_uid

        def self.parse(value, _repo)
          value && new(
            value[:url],
            value[:thumbnail_url],
            value[:title],
            value[:width],
            value[:height],
            value[:provider],
            value[:provider_url],
            value[:provider_uid],
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

        def iframe_embed(width = self.width, height = self.height)
          # rubocop:disable Layout/LineLength
          case provider
          when "youtube"
            %(<iframe width="#{width}" height="#{height}" src="//www.youtube.com/embed/#{provider_uid}?rel=0" frameborder="0" allowfullscreen></iframe>)
          when "vimeo"
            %(<iframe src="//player.vimeo.com/video/#{provider_uid}?title=0&amp;byline=0&amp;portrait=0" width="#{width}" height="#{height}" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>)
          when "facebook"
            %(<iframe src="//www.facebook.com/plugins/video.php?href=#{url}&width=#{width}&show_text=false&height=#{height}" width="#{width}" height="#{height}" style="border:none;overflow:hidden;width:100%;" scrolling="no" frameborder="0" allowTransparency="true" allow="encrypted-media" allowFullScreen="true"></iframe>)
          end
          # rubocop:enable Layout/LineLength
        end

        def to_hash(*_args)
          {
            url: url,
            thumbnail_url: thumbnail_url,
            title: title,
            width: width,
            height: height,
            provider: provider,
            provider_url: provider_url,
            provider_uid: provider_uid,
          }
        end
      end
    end
  end
end
