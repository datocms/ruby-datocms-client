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

        def self.parse(value, repo)
          value && new(
            value[:site_name],
            value[:title_suffix],
            value[:twitter_account],
            value[:facebook_page_url],
            value[:fallback_seo],
            repo
          )
        end

        def initialize(
          site_name,
          title_suffix,
          twitter_account,
          facebook_page_url,
          fallback_seo,
          repo
        )
          @site_name = site_name
          @title_suffix = title_suffix
          @twitter_account = twitter_account
          @facebook_page_url = facebook_page_url
          @fallback_seo = fallback_seo
          @repo = repo
        end

        def fallback_seo
          @fallback_seo && Seo.parse(@fallback_seo, @repo)
        end

        def to_hash(*args)
          {
            site_name: site_name,
            title_suffix: title_suffix,
            twitter_account: twitter_account,
            facebook_page_url: facebook_page_url,
            fallback_seo: fallback_seo && fallback_seo.to_hash(*args)
          }
        end
      end
    end
  end
end
