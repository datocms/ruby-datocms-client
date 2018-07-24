# frozen_string_literal: true
require 'spec_helper'

module Dato
  describe Cli do
    subject(:builder) do
      described_class.new(
        [], ["--watch"],
        shell: Thor::Shell::Color.new,
        current_command: current_command,
        command_options: options
      )
    end

    let(:current_command) do
      Thor::Command.new(
        "dump", "dumps DatoCMS content into local files", "dump", options
      )
    end

    let(:options) do
      {
        config: Thor::Option.new("config", default: "dato.config.rb"),
        token: Thor::Option.new("token", default: "atoken"),
        preview: Thor::Option.new("preview", default: "false"),
        watch: Thor::Option.new("watch", default: "true")
      }
    end

    let(:client) { instance_double(Dato::Site::Client, request: site_data) }
    let(:site_data) { {'data' => {'id' => 'id'}} }
    let(:runner) { instance_double(Dato::Dump::Runner, run: nil) }

    let(:watcher) do
      instance_double(Dato::Watch::SiteChangeWatcher, connect: nil)
    end

    before do
      allow(Dato::Site::Client).to receive(:new) { client }
      allow(Dato::Dump::Runner).
        to receive(:new).
        with(anything, anything, anything) { runner }
      allow(Dato::Watch::SiteChangeWatcher).to receive(:new) { watcher }
      allow(subject).to receive(:sleep)
    end

    describe '#dump' do
      context 'in watch mode' do
        it 'dumps data' do
          subject.dump

          expect(runner).to have_received(:run)
        end

        it 'sleeps' do
          subject.dump

          expect(subject).to have_received(:sleep)
        end
      end
    end
  end
end
