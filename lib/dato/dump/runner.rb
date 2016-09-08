# frozen_string_literal: true
require 'dato/dump/dsl/root'
require 'dato/dump/operation/root'
require 'dato/dump/ssg_detector'
require 'dato/local/loader'

module Dato
  module Dump
    class Runner
      attr_reader :config_path, :client, :destination_path

      def initialize(config_path, client, destination_path = Dir.pwd)
        @config_path = config_path
        @client = client
        @destination_path = destination_path
      end

      def run
        loader.load

        Dsl::Root.new(
          File.read(config_path),
          loader.items_repo,
          operation
        )

        operation.perform
      end

      def operation
        @operation ||= Operation::Root.new(destination_path)
      end

      def loader
        @loader ||= Dato::Local::Loader.new(client)
      end
    end
  end
end
