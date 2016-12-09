# frozen_string_literal: true
require 'spec_helper'

module Dato
  module Utils
    describe SeoTagsBuilder do
      include_context 'items repo'

      subject(:builder) { described_class.new(item, site) }

      describe '#meta_tags' do
        it 'returns an array of tags' do
          expect(builder.meta_tags).to be_an Array
          expect(builder.meta_tags.first).to be_an Hash
          expect(builder.meta_tags.first[:tag_name]).to eq :meta
        end
      end
    end
  end
end
