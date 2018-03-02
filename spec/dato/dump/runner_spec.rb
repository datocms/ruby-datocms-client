# frozen_string_literal: true
require 'spec_helper'

require 'diff_dirs'

module Dato
  module Dump
    RSpec.describe Runner, :vcr do
      include_context 'with a new site'

      subject(:runner) do
        described_class.new(config_path, client, false, destination_path)
      end

      let(:config_path) { './spec/fixtures/config.rb' }

      let(:destination_path) do
        Dir.mktmpdir
      end

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
