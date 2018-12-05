# frozen_string_literal: true

module Dato
  class Paginator
    def initialize(client, base_endpoint, filters)
      @client = client
      @base_endpoint = base_endpoint
      @filters = filters
    end

    def response
      items_per_page = 100

      base_response = @client.request(
        :get, @base_endpoint, @filters.dup.merge('page[limit]' => items_per_page)
      )

      extra_pages = (
        base_response[:meta][:total_count] / items_per_page.to_f
      ).ceil - 1

      extra_pages.times do |page|
        base_response[:data] += @client.request(
          :get,
          @base_endpoint,
          @filters.dup.merge(
            'page[offset]' => items_per_page * (page + 1),
            'page[limit]' => items_per_page
          )
        )[:data]
      end

      base_response
    end
  end
end
