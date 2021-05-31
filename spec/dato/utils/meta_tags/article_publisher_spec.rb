# frozen_string_literal: true

require "spec_helper"

module Dato
  module Utils
    module MetaTags
      describe ArticlePublisher do
        include_context "items repo"
        subject(:builder) { described_class.new(item, site) }

        describe "#build" do
          let(:result) { builder.build }

          context "with FB page not set" do
            it "returns no tags" do
              expect(result).to be_nil
            end
          end

          context "with FB page set" do
            let(:global_seo) do
              {
                facebook_page_url: "http://facebook.com/mark.smith",
              }
            end

            it "returns robots meta tag" do
              expect(result[:attributes][:content]).to eq("http://facebook.com/mark.smith")
            end
          end
        end
      end
    end
  end
end
