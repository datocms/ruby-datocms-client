# frozen_string_literal: true
require 'dato/site/repo/base'

module Dato
  module Site
    module Repo
      class SearchResult < Base
        def all
          get_request '/search-results'
        end
      end
    end
  end
end
