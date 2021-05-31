# frozen_string_literal: true

require "spec_helper"

module Dato
  module Utils
    module MetaTags
      describe ArticleModifiedTime do
        include_context "items repo"
        subject(:builder) { described_class.new(item, site) }

        describe "#build" do
          let(:result) { builder.build }

          context "with no item" do
            it "returns no tags" do
              expect(result).to be_nil
            end
          end

          context "with item" do
            let(:item) { items_repo.articles.first }

            it "returns iso 8601 datetime" do
              expect(result[:attributes][:content]).to eq("2016-12-07T09:14:22Z")
            end
          end
        end
      end
    end
  end
end
