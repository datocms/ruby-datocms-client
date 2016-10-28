# frozen_string_literal: true
require 'spec_helper'

module Dato
  module Upload
    describe File, :vcr do
      let(:account_client) do
        Dato::Account::Client.new(
          'XXX',
          base_url: 'http://account-api.lvh.me:3001'
        )
      end

      let(:site) do
        account_client.sites.create(name: 'Test site')
      end

      let(:site_client) do
        Dato::Site::Client.new(
          site[:readwrite_token],
          base_url: 'http://site-api.lvh.me:3001'
        )
      end

      subject(:command) { described_class.new(site_client, source) }

      context 'with a url' do
        let(:source) { 'https://s3.claudiaraddi.net/slideshows/original/4/Sito2.jpg' }

        it 'downloads locally and then uploads the file' do
          expect(command.upload).to eq({
            path: "/315/1477643153-Sito2.jpg",
            size: 713012,
            format: "jpg"
          })
        end
      end

      context 'with a local file' do
        let(:source) { './spec/fixtures/image.jpg' }

        it 'uploads the file' do
          expect(command.upload).to eq({
            path: "/316/1477643159-image.jpg",
            size: 4865,
            format: "jpg"
          })
        end
      end
    end
  end
end
