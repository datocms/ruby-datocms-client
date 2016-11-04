# frozen_string_literal: true
require 'spec_helper'

module Dato
  module Local
    RSpec.describe ItemsRepo, :vcr do
      subject(:repo) do
        loader.items_repo
      end

      let(:loader) do
        Loader.new(client)
      end

      let(:client) do
        Dato::Site::Client.new(
          'XYZ',
          base_url: 'http://site-api.lvh.me:3001'
        )
      end

      before do
        loader.load
      end

      describe '.to_hash' do
        it 'dump everything you might need' do
          expect(repo.available_locales).to eq [:en]
          expect(JSON.pretty_generate(repo.site.to_hash)).to eq File.read('./spec/fixtures/to_hash/site.json')

          item_types = repo.item_types.each_with_object({}) do |item_type, acc|
            acc[item_type.api_key] = repo.items_of_type(item_type).map(&:to_hash)
          end
          expect(JSON.pretty_generate(item_types)).to eq File.read('./spec/fixtures/to_hash/item_types.json')
        end
      end

      context 'multi language' do
        it 'returns localized data correctly' do
          I18n.with_locale(:it) do
            expect(repo.articles.first.title).to eq 'Titolo'
            expect(repo.articles.first.to_hash[:title]).to eq 'Titolo'
          end

          I18n.with_locale(:en) do
            expect(repo.articles.first.title).to eq 'Title'
            expect(repo.articles.first.to_hash[:title]).to eq 'Title'
          end
        end
      end
    end
  end
end
