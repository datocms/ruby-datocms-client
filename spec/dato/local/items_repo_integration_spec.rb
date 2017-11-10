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
          'd89d00dc259fb2e018451cbcaf74520f',
          base_url: 'http://site-api.lvh.me:3001'
        )
      end

      before do
        loader.load
      end

      describe '.to_hash' do
        it 'dump everything you might need' do
          expect(repo.available_locales).to eq [:it, :en]
          # File.write('./spec/fixtures/to_hash/site.json', JSON.pretty_generate(repo.site.to_hash))
          expect(JSON.pretty_generate(repo.site.to_hash)).to eq File.read('./spec/fixtures/to_hash/site.json')

          item_types = repo.item_types.each_with_object({}) do |item_type, acc|
            acc[item_type.api_key] = repo.items_of_type(item_type).map(&:to_hash)
          end
          # File.write('./spec/fixtures/to_hash/item_types.json', JSON.pretty_generate(item_types))
          expect(JSON.pretty_generate(item_types)).to eq File.read('./spec/fixtures/to_hash/item_types.json')
        end
      end

      context 'multi language' do
        it 'returns localized data correctly' do
          I18n.with_locale(:it) do
            expect(repo.articles.last.title).to eq 'La Madonna della Cintola a Santa Maria Novella '
            expect(repo.articles.last.to_hash[:title]).to eq 'La Madonna della Cintola a Santa Maria Novella '
          end

          I18n.with_locale(:en) do
            expect(repo.articles.last.title).to eq 'Our Lady of the Belt in Santa Maria Novella'
            expect(repo.articles.last.to_hash[:title]).to eq 'Our Lady of the Belt in Santa Maria Novella'
          end
        end
      end
    end
  end
end
