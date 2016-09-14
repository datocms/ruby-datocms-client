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
        print "Fetching content from DatoCMS... "

        loader.load

        I18n.available_locales = loader.items_repo.available_locales
        I18n.locale = I18n.available_locales.first

        Dsl::Root.new(
          File.read(config_path),
          loader.items_repo,
          operation
        )

        operation.perform

        puts "\e[32m✓\e[0m Done!"
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
