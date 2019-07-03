# frozen_string_literal: true

require 'spec_helper'

module Dato
  describe Cli do
    let(:client) { instance_double(Dato::Site::Client, request: site_data) }
    let(:site_data) { { 'data' => { 'id' => 'id' } } }
    let(:runner) { instance_double(Dato::Dump::Runner, run: nil) }

    before do
      allow(Dato::Site::Client).to receive(:new) { client }
      allow(client).to receive_message_chain(:items, :all).and_return({})
      allow(client).to receive_message_chain(:uploads, :all).and_return({})
      allow(Dato::Dump::Runner)
        .to receive(:new).with(anything, anything, anything, anything) { runner }
    end

    describe '#dump' do
      context 'in watch mode' do
        it 'dumps data' do
          described_class.start(%w(dump --token sometoken))
          expect(runner).to have_received(:run)
        end
      end
    end
  end
end
