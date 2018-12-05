# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Utils
    module MetaTags
      describe OgLocale do
        include_context 'items repo'

        subject(:builder) { described_class.new(item, site) }

        describe '#build' do
          it 'returns current i18n locale' do
            result = I18n.with_locale(:en) { builder.build }
            expect(result[:attributes][:content]).to eq('en_EN')
          end
        end
      end
    end
  end
end
