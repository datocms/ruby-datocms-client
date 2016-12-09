# frozen_string_literal: true
require 'spec_helper'

module Dato
  module Utils
    module MetaTags
      describe Title do
        include_context 'items repo'

        subject(:builder) { described_class.new(item, site) }

        describe '#build' do
          let(:result) { builder.build }
          let(:title_tag) { result[0][:content] }
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

              context 'with no title' do
                context 'no SEO' do
                  it 'returns no tags' do
                    expect(result).to be_nil
                  end
                end

                context 'with SEO' do
                  let(:seo) do
                    { title: 'SEO title' }
                  end

                  it 'returns seo title' do
                    expect(title_tag).to eq('SEO title')
                    expect(og_value).to eq('SEO title')
                    expect(card_value).to eq('SEO title')
                  end
                end
              end

              context 'with title' do
                let(:item_title) { 'My title' }

                context 'no SEO' do
                  it 'returns item title' do
                    expect(title_tag).to eq('My title')
                    expect(og_value).to eq('My title')
                    expect(card_value).to eq('My title')
                  end
                end

                context 'with SEO' do
                  let(:seo) do
                    { title: 'SEO title' }
                  end

                  it 'returns SEO title' do
                    expect(title_tag).to eq('SEO title')
                    expect(og_value).to eq('SEO title')
                    expect(card_value).to eq('SEO title')
                  end
                end
              end
            end
          end

          context 'with fallback seo' do
            let(:global_seo) do
              {
                title_suffix: title_suffix,
                fallback_seo: {
                  title: 'Default title'
                }
              }
            end

            context 'with no item' do
              context 'with title suffix' do
                let(:title_suffix) { ' - My site' }

                it 'returns fallback title' do
                  expect(title_tag).to eq('Default title - My site')
                  expect(og_value).to eq('Default title')
                  expect(card_value).to eq('Default title')
                end
              end

              context 'without title suffix' do
                it 'returns fallback title' do
                  expect(title_tag).to eq('Default title')
                  expect(og_value).to eq('Default title')
                  expect(card_value).to eq('Default title')
                end
              end
            end

            context 'with item' do
              let(:item) { items_repo.articles.first }

              context 'with no title' do
                context 'no SEO' do
                  it 'returns fallback title' do
                    expect(title_tag).to eq('Default title')
                    expect(og_value).to eq('Default title')
                    expect(card_value).to eq('Default title')
                  end
                end

                context 'with SEO' do
                  let(:seo) do
                    { title: 'SEO title' }
                  end

                  it 'returns seo title' do
                    expect(title_tag).to eq('SEO title')
                    expect(og_value).to eq('SEO title')
                    expect(card_value).to eq('SEO title')
                  end
                end
              end

              context 'with title' do
                let(:item_title) { 'My title' }

                context 'no SEO' do
                  it 'returns item title' do
                    expect(title_tag).to eq('My title')
                    expect(og_value).to eq('My title')
                    expect(card_value).to eq('My title')
                  end
                end

                context 'with SEO' do
                  let(:seo) do
                    { title: 'SEO title' }
                  end

                  it 'returns SEO title' do
                    expect(title_tag).to eq('SEO title')
                    expect(og_value).to eq('SEO title')
                    expect(card_value).to eq('SEO title')
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
