# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Utils
    module MetaTags
      describe Description do
        include_context 'items repo'

        subject(:builder) { described_class.new(item, site) }

        describe '#build' do
          let(:result) { builder.build }
          let(:description_value) { result[0][:attributes][:content] }
          let(:og_value) { result[1][:attributes][:content] }
          let(:card_value) { result[2][:attributes][:content] }

          context 'with no fallback seo' do
            context 'with no item' do
              it 'returns no tags' do
                expect(result).to be_nil
              end
            end

            context 'with item' do
              let(:item) { items_repo.articles.first }

              context 'no SEO' do
                it 'returns no tags' do
                  expect(result).to be_nil
                end
              end

              context 'with SEO' do
                let(:seo) do
                  { description: 'SEO description' }
                end

                it 'returns seo description' do
                  expect(description_value).to eq('SEO description')
                  expect(og_value).to eq('SEO description')
                  expect(card_value).to eq('SEO description')
                end
              end
            end
          end

          context 'with fallback seo' do
            let(:global_seo) do
              {
                fallback_seo: {
                  description: 'Default description'
                }
              }
            end

            context 'with no item' do
              it 'returns fallback description' do
                expect(description_value).to eq('Default description')
                expect(og_value).to eq('Default description')
                expect(card_value).to eq('Default description')
              end
            end

            context 'with item' do
              let(:item) { items_repo.articles.first }

              context 'no SEO' do
                it 'returns fallback description' do
                  expect(description_value).to eq('Default description')
                  expect(og_value).to eq('Default description')
                  expect(card_value).to eq('Default description')
                end
              end

              context 'with SEO' do
                let(:seo) do
                  { description: 'SEO description' }
                end

                it 'returns seo description' do
                  expect(description_value).to eq('SEO description')
                  expect(og_value).to eq('SEO description')
                  expect(card_value).to eq('SEO description')
                end
              end
            end
          end
        end
      end
    end
  end
end
