# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Local
    module FieldType
      RSpec.describe Dato::Local::FieldType::Color do
        subject(:file) { described_class.parse(attributes, nil) }
        let(:attributes) do
          {
            red: 255,
            green: 127,
            blue: 0,
            alpha: 255
          }
        end

        it 'responds to red, green, blue, hex and rgb methods' do
          expect(file.red).to eq 255
          expect(file.green).to eq 127
          expect(file.blue).to eq 0
          expect(file.alpha).to eq 1.0
          expect(file.rgb).to eq 'rgb(255, 127, 0)'
          expect(file.hex).to eq '#ff7f00'
        end
      end
    end
  end
end
