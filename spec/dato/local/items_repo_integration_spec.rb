# frozen_string_literal: true
require 'spec_helper'

module Dato
  module Local
    RSpec.describe ItemsRepo, :vcr do
      include_context 'with a new site'

      subject(:repo) do
        loader.items_repo
      end

      let(:loader) do
        Loader.new(client)
      end

      before do
        loader.load
      end

      describe '.to_hash' do
        it 'dump everything you might need' do
          expect(repo.available_locales).to eq [:en, :it]

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
            expect(repo.articles.last.title).to eq 'Primo post'
            expect(repo.articles.last.to_hash[:title]).to eq 'Primo post'
          end

          I18n.with_locale(:en) do
            expect(repo.articles.last.title).to eq 'First post'
            expect(repo.articles.last.to_hash[:title]).to eq 'First post'
          end
        end
      end
    end
  end
end
