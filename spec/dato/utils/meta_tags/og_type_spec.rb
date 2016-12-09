# frozen_string_literal: true
require 'spec_helper'

module Dato
  module Utils
    module MetaTags
      describe OgType do
        include_context 'items repo'

        subject(:builder) { described_class.new(item, site) }

        describe '#build' do
          let(:result) { builder.build }

          context 'with no item' do
            it 'returns website og:type' do
              expect(result[:attributes][:content]).to eq('website')
            end
          end

          context 'with item' do
            let(:item) { items_repo.articles.first }

            it 'returns article og:type' do
              expect(result[:attributes][:content]).to eq('article')
            end
          end
        end
      end
    end
  end
end
