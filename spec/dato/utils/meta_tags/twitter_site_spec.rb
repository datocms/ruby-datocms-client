# frozen_string_literal: true

require "spec_helper"

module Dato
  module Utils
    module MetaTags
      describe TwitterSite do
        include_context "items repo"

        subject(:builder) { described_class.new(item, site) }

        describe "#build" do
          let(:result) { builder.build }

          context "with twitter account not set" do
            it "returns no tags" do
              expect(result).to be_nil
            end
          end

          context "with twitter account set" do
            let(:global_seo) do
              {
                twitter_account: "@steffoz",
              }
            end

            it "returns robots meta tag" do
              expect(result[:attributes][:content]).to eq("@steffoz")
            end
          end
        end
      end
    end
  end
end
