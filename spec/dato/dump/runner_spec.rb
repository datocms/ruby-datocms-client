# frozen_string_literal: true

require 'spec_helper'
require 'front_matter_parser'

module Dato
  module Dump
    RSpec.describe Runner, :vcr do
      include_context 'with a new site'

      subject(:runner) do
        described_class.new(config_path, client, false, loader, destination_path)
      end

      let(:config_path) { './spec/fixtures/config.rb' }

      let(:destination_path) do
        Dir.mktmpdir
      end

      let(:loader) { Dato::Local::Loader.new(client) }

      describe '.run' do
        before do
          loader.load
          runner.run
        end

        it 'generates directories and files' do
          toml_file = TOML.load(File.read(File.join(destination_path, 'foobar.toml')))
          expect(toml_file['sitename']).to eq 'Integration new test site'

          yaml_file = YAML.safe_load(File.read(File.join(destination_path, 'site.yml')))
          expect(yaml_file['name']).to eq 'Integration new test site'
          expect(yaml_file['locales']).to eq %w[en it]

          loader = FrontMatterParser::Loader::Yaml.new(whitelist_classes: [Time])
          article_file = FrontMatterParser::Parser.new(:md, loader: loader).call(
            File.read(File.join(destination_path, 'posts', 'first-post.md'))
          )

          expect(article_file.front_matter['item_type']).to eq 'article'
          expect(article_file.front_matter['updated_at']).to be_present
          expect(article_file.front_matter['created_at']).to be_present
          expect(article_file.front_matter['title']).to eq 'First post'
          expect(article_file.front_matter['slug']).to eq 'first-post'
          expect(article_file.front_matter['image']['format']).to eq 'png'
          expect(article_file.front_matter['image']['size']).to eq 119_271
          expect(article_file.front_matter['image']['height']).to eq 621
          expect(article_file.front_matter['image']['width']).to eq 2553
          expect(article_file.front_matter['image']['url']).to be_present
          expect(article_file.front_matter['file']['format']).to eq 'txt'
          expect(article_file.front_matter['file']['size']).to eq 10
          expect(article_file.front_matter['file']['url']).to be_present

          expect(article_file.content).to eq 'First post'
        end
      end
    end
  end
end
