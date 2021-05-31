# frozen_string_literal: true

require 'spec_helper'

module Dato
  describe JsonApiSerializer do
    subject(:serializer) do
      described_class.new(type: 'menu_item', link: link)
    end

    let(:link) do
      response = VCR.use_cassette('json_schema', record: :new_episodes) do
        url = URI.parse('https://site-api.datocms.com/docs/site-api-hyperschema.json')
        Net::HTTP.get(url)
      end

      schema = JsonSchema.parse!(JSON.parse(response))
      schema.expand_references!

      schema.definitions['menu_item'].links.find do |x|
        x.rel == 'create'
      end
    end

    describe '#serialize' do
      it 'returns a JSON-API serialized version of the argument' do
        expect(serializer.serialize({ label: 'Ciao', position: 1 }, '12')).to eq(
          data: {
            id: '12',
            type: 'menu_item',
            attributes: {
              label: 'Ciao',
              position: 1
            }
          }
        )
      end
    end
  end
end
