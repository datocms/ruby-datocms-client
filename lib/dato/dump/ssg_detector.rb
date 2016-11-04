# frozen_string_literal: true
require 'toml'
require 'json'
require 'yaml'

module Dato
  module Dump
    class SsgDetector
      attr_reader :path

      RUBY = %w(middleman jekyll nanoc).freeze

      NODE = %w(brunch assemble ember-cli hexo metalsmith react-scripts
                roots docpad wintersmith gatsby harp grunt gulp).freeze

      PYTHON = %w(mkdocs pelican cactus).freeze

      HUGO = [
        {
          file: 'config.toml',
          loader: ->(content) { TOML::Parser.new(content).parsed }
        },
        {
          file: 'config.yaml',
          loader: ->(content) { YAML.load(content) }
        },
        {
          file: 'config.json',
          loader: ->(content) { JSON.parse(content) }
        }
      ].freeze

      def initialize(path)
        @path = path
      end

      def detect
        ruby_generator ||
          node_generator ||
          python_generator ||
          hugo ||
          'unknown'
      end

      private

      def ruby_generator
        gemfile_path = File.join(path, 'Gemfile')
        return unless File.exist?(gemfile_path)

        gemfile = File.read(gemfile_path)

        RUBY.find do |generator|
          gemfile =~ /('#{generator}'|"#{generator}")/
        end
      end

      def node_generator
        package_path = File.join(path, 'package.json')
        return unless File.exist?(package_path)

        package = JSON.parse(File.read(package_path))

        deps = package.fetch('dependencies', {})
        dev_deps = package.fetch('devDependencies', {})
        all_deps = deps.merge(dev_deps)

        NODE.find do |generator|
          all_deps.key? generator
        end
      rescue JSON::ParserError
        nil
      end

      def python_generator
        requirements_path = File.join(path, 'requirements.txt')
        return unless File.exist?(requirements_path)

        requirements = File.read(requirements_path)

        PYTHON.find do |generator|
          requirements =~ /^#{generator}(==)?/
        end
      end

      def hugo
        HUGO.any? do |option|
          config_path = File.join(path, option[:file])
          if File.exist?(config_path)
            config = option[:loader].call(File.read(config_path))
            config.key? 'baseurl'
          end
        end && 'hugo'
      rescue JSON::ParserError
        nil
      rescue Psych::SyntaxError
        nil
      end
    end
  end
end
