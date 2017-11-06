# frozen_string_literal: true
require 'dato/site/repo/base'

module Dato
  module Site
    module Repo
      class Site < Base
        def find
          get_request '/site'
        end

        def update(resource_attributes)
          body = JsonApiSerializer.new(
            type: :site,
            attributes: %i(favicon global_seo locales name no_index production_deploy_adapter production_deploy_settings production_frontend_url production_spider_enabled require_2fa ssg staging_deploy_adapter staging_deploy_settings staging_frontend_url staging_spider_enabled theme timezone)
          ).serialize(resource_attributes)

          put_request '/site', body
        end
      end
    end
  end
end
