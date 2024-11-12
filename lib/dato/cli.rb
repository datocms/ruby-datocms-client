# frozen_string_literal: true

require "thor"
require "dato/dump/runner"
require "dato/dump/ssg_detector"
require "listen"
module Dato
  class Cli < Thor
    package_name "DatoCMS"

    desc "dump", "dumps DatoCMS content into local files"
    option :config, default: "dato.config.rb"
    option :token, default: ENV["DATO_API_TOKEN"], required: true
    option :environment, type: :string, required: false
    option :preview, default: false, type: :boolean
    option :watch, default: false, type: :boolean

    def dump
      config_file = File.expand_path(options[:config])
      watch_mode = options[:watch]
      preview_mode = options[:preview]

      client = Dato::Site::Client.new(
        options[:token],
        environment: options[:environment],
        extra_headers: {
          "X-Reason" => "dump",
          "X-SSG" => Dump::SsgDetector.new(Dir.pwd).detect,
        },
      )
      loader = Dato::Local::Loader.new(client, preview_mode)
      puts "Fetching content from DatoCMS..."
      loader.load

      if watch_mode
        semaphore = Mutex.new

        thread_safe_dump(semaphore, config_file, client, preview_mode, loader)

        loader.watch do
          thread_safe_dump(semaphore, config_file, client, preview_mode, loader)
        end

        watch_config_file(config_file) do
          thread_safe_dump(semaphore, config_file, client, preview_mode, loader)
        end

        sleep
      else
        Dump::Runner.new(config_file, client, preview_mode, loader).run
      end
    end

    desc "check", "checks the presence of a DatoCMS token"
    def check
      exit 0 if ENV["DATO_API_TOKEN"]

      say "Site token is not specified!"
      token = ask "Please paste your DatoCMS site read-only API token:\n>"

      if !token || token.empty?
        puts "Missing token"
        exit 1
      end

      File.open(".env", "a") do |file|
        file.puts "DATO_API_TOKEN=#{token}"
      end

      say "Token added to .env file."

      exit 0
    end

    no_tasks do
      def watch_config_file(config_file, &block)
        Listen.to(
          File.dirname(config_file),
          only: /#{Regexp.quote(File.basename(config_file))}/,
          &block
        ).start
      end

      def thread_safe_dump(semaphore, config_file, client, preview_mode, loader)
        semaphore.synchronize do
          Dump::Runner.new(config_file, client, preview_mode, loader).run
        end
      end
    end
  end
end
