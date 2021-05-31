# frozen_string_literal: true

require "spec_helper"

module Dato
  module Dump
    RSpec.describe SsgDetector do
      subject(:detector) { described_class.new(path) }

      describe ".detect" do
        context "package.json-based SSGs" do
          let(:path) { "./spec/fixtures/ssg/hexo" }

          it "detects it" do
            expect(detector.detect).to eq "hexo"
          end
        end

        context "Gemfile-based SSGs" do
          let(:path) { "./spec/fixtures/ssg/middleman" }

          it "detects it" do
            expect(detector.detect).to eq "middleman"
          end
        end

        context "Hugo SSGs" do
          context "with config.toml" do
            let(:path) { "./spec/fixtures/ssg/hugo/toml" }

            it "detects it" do
              expect(detector.detect).to eq "hugo"
            end
          end

          context "with config.yaml" do
            let(:path) { "./spec/fixtures/ssg/hugo/yaml" }

            it "detects it" do
              expect(detector.detect).to eq "hugo"
            end
          end

          context "with config.json" do
            let(:path) { "./spec/fixtures/ssg/hugo/json" }

            it "detects it" do
              expect(detector.detect).to eq "hugo"
            end
          end
        end

        context "otherwise" do
          let(:path) { "." }

          it 'fall backs to "unknown"' do
            expect(detector.detect).to eq "unknown"
          end
        end
      end
    end
  end
end
