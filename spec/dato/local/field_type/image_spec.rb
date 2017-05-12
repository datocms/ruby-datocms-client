# frozen_string_literal: true
require 'spec_helper'

module Dato
  module Local
    module FieldType
      RSpec.describe Image do
        subject(:image) { described_class.parse(attributes, repo) }

        let(:repo) { instance_double('Dato::Local::ItemsRepo', site: site) }
        let(:site) { instance_double('Dato::Local::Site', entity: site_entity) }
        let(:site_entity) { double('Dato::Local::JsonApiEntity', imgix_host: 'foobar.com') }

        let(:attributes) do
          {
            path: '/foo.png',
            format: 'jpg',
            size: 4000,
            width: 20,
            height: 20
          }
        end

        it 'responds to path, format, size, width and height' do
          expect(image.path).to eq '/foo.png'
          expect(image.format).to eq 'jpg'
          expect(image.size).to eq 4000
          expect(image.width).to eq 20
          expect(image.height).to eq 20
        end
      end
    end
  end
end
