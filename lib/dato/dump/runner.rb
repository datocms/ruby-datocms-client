# frozen_string_literal: true
require 'dato/dump/dsl/root'
require 'dato/dump/operation/root'

module Dato
  module Dump
    class Runner
      attr_reader :config_path, :api_token

      def initialize(config_path, api_token)
        @config_path = config_path
        @api_token = api_token
      end

      def run
        site.load

        root = Operation::Root.new(Dir.pwd)

        Dsl::Root.new(
          File.read(config_path),
          site.items_repo,
          root
        )

        root.perform
      end

      def site
        @site ||= Dato::Local::Site.new(client)
      end

      def client
        @client ||= Dato::Site::Client.new(api_token)
      end
    end
  end
end
