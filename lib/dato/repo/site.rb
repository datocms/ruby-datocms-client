require 'dato/repo/base'

module Dato
  module Repo
    class Site < Base

      def find()
        get_request "/site"
      end

      def update(resource_attributes)
        body = JsonApiSerializer.new(
          type: :site,
          attributes: %i(deploy_adapter deploy_settings favicon global_seo locales name no_index theme_hue timezone),
        ).serialize(resource_attributes)

        put_request "/site", body
      end

    end
  end
end
