# frozen_string_literal: true

require "spec_helper"

module Dato
  module Utils
    module MetaTags
      describe TwitterCard do
        include_context "items repo"

        subject(:builder) { described_class.new(item, site) }

        describe "#build" do
          let(:result) { builder.build }
          let(:card_value) { result[:attributes][:content] }

          context "with no fallback seo" do
            context "with no item" do
              it "returns no tags" do
                expect(card_value).to eq("summary")
              end
            end

            context "with item" do
              let(:item) { items_repo.articles.first }

              context "with no title" do
                context "no SEO" do
                  it "returns no tags" do
                    expect(card_value).to eq("summary")
                  end
                end

                context "with SEO" do
                  let(:seo) do
                    { twitter_card: "foobar" }
                  end

                  it "returns seo title" do
                    expect(card_value).to eq("foobar")
                  end
                end
              end
            end
          end

          context "with fallback seo" do
            let(:global_seo) do
              {
                fallback_seo: {
                  twitter_card: "default_summary",
                },
              }
            end

            context "with no item" do
              it "returns fallback title" do
                expect(card_value).to eq("default_summary")
              end
            end

            context "with item" do
              let(:item) { items_repo.articles.first }

              context "no SEO" do
                it "returns fallback title" do
                  expect(card_value).to eq("default_summary")
                end
              end

              context "with SEO" do
                let(:seo) do
                  { twitter_card: "item_summary" }
                end

                it "returns seo title" do
                  expect(card_value).to eq("item_summary")
                end
              end
            end
          end
        end
      end
    end
  end
end
