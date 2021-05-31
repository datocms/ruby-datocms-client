# frozen_string_literal: true

require "spec_helper"

module Dato
  module Utils
    module MetaTags
      describe OgSiteName do
        include_context "items repo"

        subject(:builder) { described_class.new(item, site) }

        describe "#build" do
          let(:result) { builder.build }

          context "with site name not set" do
            it "returns no tags" do
              expect(result).to be_nil
            end
          end

          context "with site name set" do
            let(:global_seo) do
              { site_name: "My site" }
            end

            it "returns og:site_name tag" do
              expect(result[:attributes][:content]).to eq("My site")
            end
          end
        end
      end
    end
  end
end
