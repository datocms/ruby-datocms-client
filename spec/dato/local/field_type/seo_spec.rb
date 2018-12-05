# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Local
    module FieldType
      RSpec.describe Seo do
        subject(:seo) { described_class.parse(attributes, repo) }

        let(:repo) { instance_double('Dato::Local::ItemsRepo', site: site, entities_repo: entities_repo) }
        let(:site) { instance_double('Dato::Local::Site', entity: site_entity) }
        let(:site_entity) { double('Dato::Local::JsonApiEntity', imgix_host: 'foobar.com') }
        let(:entities_repo) { instance_double('Dato::Local::EntitiesRepo', find_entity: upload_entity) }
        let(:upload_entity) { double('Dato::Local::JsonApiEntity', upload_attributes) }

        let(:attributes) do
          {
            title: 'title',
            description: 'description',
            image: '333'
          }
        end

        let(:upload_attributes) do
          {
            path: '/foo.png',
            format: 'jpg',
            size: 4000,
            width: 20,
            height: 20,
            alt: 'an alt',
            title: 'a title'
          }
        end

        it 'responds to title, description and image methods' do
          expect(seo.title).to eq 'title'
          expect(seo.description).to eq 'description'
          expect(seo.image).to be_a Dato::Local::FieldType::File
          expect(seo.image.path).to eq '/foo.png'
          expect(seo.image.format).to eq 'jpg'
          expect(seo.image.size).to eq 4000
          expect(seo.image.width).to eq 20
          expect(seo.image.height).to eq 20
        end
      end
    end
  end
end
