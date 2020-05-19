# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Utils
    describe BuildModularBlock do
      describe '#build' do
        it 'returns an array of tags' do
          attributes = {
            id: '111',
            item_type: '1234',
            title: 'Title',
            description: 'Description'
          }
          payload = {
            id: '111',
            type: 'item',
            attributes: {
              title: 'Title',
              description: 'Description'
            },
            relationships: {
              item_type: {
                data: {
                  id: '1234',
                  type: 'item_type',
                },
              },
            },
          }
          expect(BuildModularBlock.build(attributes)).to eq payload

        end
      end
    end
  end
end
