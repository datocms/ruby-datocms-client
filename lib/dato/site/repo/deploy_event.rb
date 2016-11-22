# frozen_string_literal: true
require 'dato/site/repo/base'

module Dato
  module Site
    module Repo
      class DeployEvent < Base
        def all
          get_request '/deploy-events'
        end

        def find(deploy_event_id)
          get_request "/deploy-events/#{deploy_event_id}"
        end
      end
    end
  end
end
