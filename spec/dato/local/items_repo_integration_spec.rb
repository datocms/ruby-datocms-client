# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Local
    RSpec.describe ItemsRepo, :vcr do
      include_context 'with a new site'

      subject(:repo) do
        loader = Loader.new(client)
        loader.load
        loader.items_repo
      end

      describe '.to_hash' do
        it 'dump everything you might need' do
          expect(repo.available_locales).to eq %i[en it]

          serialized_site = repo.site.to_hash
          expect(serialized_site[:name]).to eq 'Integration new test site'
          expect(serialized_site[:locales]).to eq %w[en it]

          serialized_article = repo.items_of_type(repo.item_types.first).first.to_hash

          expect(serialized_article[:item_type]).to eq 'article'
          expect(serialized_article[:updated_at]).to be_present
          expect(serialized_article[:created_at]).to be_present
          expect(serialized_article[:title]).to eq 'First post'
          expect(serialized_article[:slug]).to eq 'first-post'
          expect(serialized_article[:image][:format]).to eq 'png'
          expect(serialized_article[:image][:size]).to eq 21_395
          expect(serialized_article[:image][:height]).to eq 398
          expect(serialized_article[:image][:width]).to eq 650
          expect(serialized_article[:image][:url]).to be_present
          expect(serialized_article[:file][:format]).to eq 'txt'
          expect(serialized_article[:file][:size]).to eq 10
          expect(serialized_article[:file][:url]).to be_present
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
