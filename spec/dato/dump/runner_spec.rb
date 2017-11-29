# frozen_string_literal: true
require 'spec_helper'

require 'diff_dirs'

module Dato
  module Dump
    RSpec.describe Runner, :vcr do
      subject(:runner) do
        described_class.new(config_path, client, destination_path)
      end

      let(:destination_path) do
        Dir.mktmpdir
      end

      let(:client) do
        Dato::Site::Client.new(
          '1b3a3699366bc5494d9d62aca7cd4202bf3df85b124d3d2f07',
          base_url: 'http://site-api.lvh.me:3001'
        )
      end

      let(:config_path) { './spec/fixtures/config.rb' }

      describe '.run' do
        before do
          runner.run
        end

        it 'generates directories and files' do
          diff = DiffDirs.diff_dirs(
            destination_path,
            './spec/fixtures/dump'
          )
          expect(diff).to be_empty
        end
      end
    end
  end
end
