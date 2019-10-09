# frozen_string_literal: true

module Dato
  class ApiError < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def message
      [
        'DatoCMS API Error',
        "Status: #{response[:status]}",
        'Response:',
        JSON.pretty_generate(body)
      ].join("\n")
    end

    def body
      if response[:body]
        JSON.parse(response[:body])
      end
    end
  end
end
