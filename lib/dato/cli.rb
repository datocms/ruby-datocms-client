# frozen_string_literal: true
require 'thor'
require 'dato/dump/runner'
require 'dato/migrate_slugs/runner'

module Dato
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

      Dump::Runner.new(config_file, client).run
    end

    desc 'migrate-slugs', 'migrates a Site so that it uses slug fields'
    option :token, default: ENV['DATO_API_TOKEN'], required: true
    option :skip_id_prefix, type: :boolean
    def migrate_slugs
      client = Dato::Site::Client.new(
        options[:token],
        base_url: 'http://site-api.lvh.me:3001',
        extra_headers: {
          'X-Reason' => 'migrate-slugs'
        }
      )

      MigrateSlugs::Runner.new(client, options[:skip_id_prefix]).run
    end
  end
end
