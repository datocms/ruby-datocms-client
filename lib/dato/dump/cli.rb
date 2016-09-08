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

        client = Dato::Site::Client.new(
          options[:token],
          extra_headers: {
            'X-Reason' => 'dump',
            'X-SSG' => SsgDetector.new(Dir.pwd).detect
          }
        )

        Runner.new(config_file, client).run
      end
    end
  end
end
