# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Utils
    module MetaTags
      describe Image do
        include_context 'items repo'

        subject(:builder) { described_class.new(item, site) }

        describe '#build' do
          let(:result) { builder.build }
          let(:og_value) { result[0][:attributes][:content] }
          let(:card_value) { result[1][:attributes][:content] }

          context 'with no fallback seo' do
            context 'with no item' do
              it 'returns no tags' do
                expect(result).to be_nil
              end
            end

            context 'with item' do
              let(:item) { items_repo.articles.first }

              context 'with no image' do
                context 'no SEO' do
                  it 'returns no tags' do
                    expect(result).to be_nil
                  end
                end

                context 'with SEO' do
                  let(:seo) do
                    {
                      image: '666'
                    }
                  end

                  it 'returns seo image' do
                    expect(og_value).to include('seo.png')
                    expect(card_value).to include('seo.png')
                  end
                end
              end

              context 'with image' do
                let(:item_image) { '111' }

                context 'no SEO' do
                  it 'returns item image' do
                    expect(og_value).to include('image.png')
                    expect(card_value).to include('image.png')
                  end
                end

                context 'with SEO' do
                  let(:seo) do
                    {
                      image: '666'
                    }
                  end

                  it 'returns SEO image' do
                    expect(og_value).to include('seo.png')
                    expect(card_value).to include('seo.png')
                  end
                end
              end
            end

            context 'with fallback seo' do
              let(:global_seo) do
                {
                  fallback_seo: {
                    image: '999'
                  }
                }
              end

              context 'with no item' do
                it 'returns fallback image' do
                  expect(og_value).to include('fallback_seo.png')
                  expect(card_value).to include('fallback_seo.png')
                end
              end

              context 'with item' do
                let(:item) { items_repo.articles.first }

                context 'with no image' do
                  context 'no SEO' do
                    it 'returns fallback image' do
                      expect(og_value).to include('fallback_seo.png')
                      expect(card_value).to include('fallback_seo.png')
                    end
                  end

                  context 'with SEO' do
                    let(:seo) do
                      {
                        image: '666'
                      }
                    end

                    it 'returns seo image' do
                      expect(og_value).to include('seo.png')
                      expect(card_value).to include('seo.png')
                    end
                  end
                end

                context 'with image' do
                  let(:item_image) { '111' }

                  context 'no SEO' do
                    it 'returns item image' do
                      expect(og_value).to include('image.png')
                      expect(card_value).to include('image.png')
                    end
                  end

                  context 'with SEO' do
                    let(:seo) do
                      {
                        image: '666'
                      }
                    end

                    it 'returns SEO image' do
                      expect(og_value).to include('seo.png')
                      expect(card_value).to include('seo.png')
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
end
