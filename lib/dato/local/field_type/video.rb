# frozen_string_literal: true

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

        def iframe_embed(width = self.width, height = self.height)
          # rubocop:disable Metrics/LineLength
          if provider == 'youtube'
            %(<iframe width="#{width}" height="#{height}" src="//www.youtube.com/embed/#{provider_uid}?rel=0" frameborder="0" allowfullscreen></iframe>)
          elsif provider == 'vimeo'
            %(<iframe src="//player.vimeo.com/video/#{provider_uid}?title=0&amp;byline=0&amp;portrait=0" width="#{width}" height="#{height}" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>)
          elsif provider == 'facebook'
            %(<iframe src="//www.facebook.com/plugins/video.php?href=#{url}&width=#{width}&show_text=false&height=#{height}" width="#{width}" height="#{height}" style="border:none;overflow:hidden;width:100%;" scrolling="no" frameborder="0" allowTransparency="true" allow="encrypted-media" allowFullScreen="true"></iframe>)
          end
          # rubocop:enable Metrics/LineLength
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
            provider_uid: provider_uid
          }
        end
      end
    end
  end
end
