# frozen_string_literal: true
require 'dato/local/field_type/seo'

module Dato
  module Local
    module FieldType
      class GlobalSeo
        attr_reader :site_name
        attr_reader :title_suffix
        attr_reader :twitter_account
        attr_reader :facebook_page_url

        def self.parse(value, _repo)
          value && new(
            value[:site_name],
            value[:title_suffix],
            value[:twitter_account],
            value[:facebook_page_url],
            value[:fallback_seo]
          )
        end

        def initialize(
          site_name,
          title_suffix,
          twitter_account,
          facebook_page_url,
          fallback_seo
        )
          @site_name = site_name
          @title_suffix = title_suffix
          @twitter_account = twitter_account
          @facebook_page_url = facebook_page_url
          @fallback_seo = fallback_seo
        end

        def fallback_seo
          @fallback_seo && Seo.parse(@fallback_seo, nil)
        end

        def to_hash
          {
            site_name: site_name,
            title_suffix: title_suffix,
            twitter_account: twitter_account,
            facebook_page_url: facebook_page_url,
            fallback_seo: fallback_seo && fallback_seo.to_hash
          }
        end
      end
    end
  end
end
