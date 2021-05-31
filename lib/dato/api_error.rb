# frozen_string_literal: true

module Dato
  class ApiError < StandardError
    attr_reader :response, :body

    def initialize(response)
      body = JSON.parse(response[:body]) if response[:body]

      message = [
        "DatoCMS API Error",
        "Status: #{response[:status]}",
        "Response:",
        JSON.pretty_generate(body),
      ].join("\n")

      super(message)

      @response = response
      @body = body
    end
  end
end
