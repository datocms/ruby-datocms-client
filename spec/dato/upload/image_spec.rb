# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Upload
    describe Image, :vcr do
      let(:account_client) do
        generate_account_client!
      end

      let(:site) do
        account_client.sites.create(name: 'Test site')
      end

      before { site }

      let(:site_client) do
        Dato::Site::Client.new(
          site[:readwrite_token],
          base_url: 'http://site-api.lvh.me:3001'
        )
      end

      subject(:command) do
        described_class.new(site_client, source)
      end

      context 'with a url' do
        let(:source) { 'https://s3.claudiaraddi.net/slideshows/original/4/Sito2.jpg' }

        it 'downloads locally and then uploads the file' do
          expect(command.upload).not_to be_nil
        end
        context 'with a 404 url' do
          let(:source) { 'https://google.it/NonExistentImage.png' }
  
          it 'raise an exception' do
            expect { command.upload }.to raise_error(Faraday::ResourceNotFound)
          end
        end
      end

      context 'with a local file' do
        let(:source) { './spec/fixtures/image.jpg' }

        it 'uploads the file' do
          expect(command.upload).not_to be_nil
        end

        context "jpg without extension" do
          let(:source) { './spec/fixtures/image' }
          it 'uploads the file' do
            expect(command.upload).not_to be_nil
          end
        end

        context "no image file" do
          let(:source) { './spec/fixtures/file.txt' }
          it 'returns format error' do
            expect {command.upload }.to raise_error(FastImage::UnknownImageType)
          end
        end
      end
      
    end
  end
end
