# frozen_string_literal: true
require 'thor'
require 'dato/dump/runner'

module Dato
  module Dump
    class Cli < Thor
      package_name 'DatoCMS'

      desc 'dump', 'dumps DatoCMS contents into local files'
      option :config, default: 'dato.config.rb'
      option :token, default: ENV['DATO_API_TOKEN'], required: true
      def dump
        config_file = File.expand_path(options[:config])
        Runner.new(config_file, options[:token]).run
      end
    end
  end
end
