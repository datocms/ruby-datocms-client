# frozen_string_literal: true
require 'dato/dump/dsl/root'
require 'dato/dump/operation/root'
require 'dato/dump/ssg_detector'

module Dato
  module Dump
    class Runner
      attr_reader :config_path, :api_token

      def initialize(config_path, api_token)
        @config_path = config_path
        @api_token = api_token
      end

      def run
        Dsl::Root.new(
          File.read(config_path),
          site.items_repo,
          operation
        )

        site.load
        operation.perform
      end

      def operation
        @operation ||= Operation::Root.new(Dir.pwd)
      end

      def site
        @site ||= Dato::Local::Site.new(client)
      end

      def client
        @client ||= Dato::Site::Client.new(
          api_token,
          extra_headers: {
            'X-Reason' => 'dump',
            'X-SSG' => generator
          }
        )
      end

      def generator
        SsgDetector.new(Dir.pwd).detect
      end
    end
  end
end
