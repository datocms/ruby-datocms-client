# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Utils
    module MetaTags
      describe Robots do
        include_context 'items repo'

        subject(:builder) { described_class.new(item, site) }

        describe '#build' do
          let(:result) { builder.build }

          context 'with site noIndex set' do
            let(:no_index) { true }

            it 'returns robots meta tag' do
              expect(result[:attributes][:content]).to eq('noindex')
            end
          end

          context 'with site noIndex not set' do
            it 'returns no tags' do
              expect(result).to be_nil
            end
          end
        end
      end
    end
  end
end
