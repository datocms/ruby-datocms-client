# frozen_string_literal: true

require "spec_helper"

module Dato
  module Utils
    describe FaviconTagsBuilder do
      include_context "items repo"

      subject(:builder) { described_class.new(site, "#ff0000") }

      describe "#meta_tags" do
        context "with no favicon" do
          let(:favicon) { nil }

          it "returns an array of tags" do
            expect(builder.meta_tags).to eq [
              { tag_name: "meta", attributes: { name: "theme-color", content: "#ff0000" } },
              { tag_name: "meta", attributes: { name: "msapplication-TileColor", content: "#ff0000" } },
              { tag_name: "meta", attributes: { name: "application-name", content: "XXX" } },
            ]
          end
        end

        context "with favicon" do
          let(:favicon) { "666" }

          it "returns an array of tags" do
            expect(builder.meta_tags).to eq [
              { tag_name: "link", attributes: { sizes: "16x16", type: "image/png", rel: "icon", href: "https://www.datocms-assets.com/seo.png?w=16&h=16" } },
              { tag_name: "link", attributes: { sizes: "32x32", type: "image/png", rel: "icon", href: "https://www.datocms-assets.com/seo.png?w=32&h=32" } },
              { tag_name: "link", attributes: { sizes: "96x96", type: "image/png", rel: "icon", href: "https://www.datocms-assets.com/seo.png?w=96&h=96" } },
              { tag_name: "link", attributes: { sizes: "192x192", type: "image/png", rel: "icon", href: "https://www.datocms-assets.com/seo.png?w=192&h=192" } },
              { tag_name: "link", attributes: { sizes: "57x57", rel: "apple-touch-icon", href: "https://www.datocms-assets.com/seo.png?w=57&h=57" } },
              { tag_name: "link", attributes: { sizes: "60x60", rel: "apple-touch-icon", href: "https://www.datocms-assets.com/seo.png?w=60&h=60" } },
              { tag_name: "link", attributes: { sizes: "72x72", rel: "apple-touch-icon", href: "https://www.datocms-assets.com/seo.png?w=72&h=72" } },
              { tag_name: "link", attributes: { sizes: "76x76", rel: "apple-touch-icon", href: "https://www.datocms-assets.com/seo.png?w=76&h=76" } },
              { tag_name: "link", attributes: { sizes: "114x114", rel: "apple-touch-icon", href: "https://www.datocms-assets.com/seo.png?w=114&h=114" } },
              { tag_name: "link", attributes: { sizes: "120x120", rel: "apple-touch-icon", href: "https://www.datocms-assets.com/seo.png?w=120&h=120" } },
              { tag_name: "link", attributes: { sizes: "144x144", rel: "apple-touch-icon", href: "https://www.datocms-assets.com/seo.png?w=144&h=144" } },
              { tag_name: "link", attributes: { sizes: "152x152", rel: "apple-touch-icon", href: "https://www.datocms-assets.com/seo.png?w=152&h=152" } },
              { tag_name: "link", attributes: { sizes: "180x180", rel: "apple-touch-icon", href: "https://www.datocms-assets.com/seo.png?w=180&h=180" } },
              { tag_name: "meta", attributes: { name: "msapplication-square70x70logo", content: "https://www.datocms-assets.com/seo.png?w=70&h=70" } },
              { tag_name: "meta", attributes: { name: "msapplication-square150x150logo", content: "https://www.datocms-assets.com/seo.png?w=150&h=150" } },
              { tag_name: "meta", attributes: { name: "msapplication-square310x310logo", content: "https://www.datocms-assets.com/seo.png?w=310&h=310" } },
              { tag_name: "meta", attributes: { name: "msapplication-square310x150logo", content: "https://www.datocms-assets.com/seo.png?w=310&h=150" } },
              { tag_name: "meta", attributes: { name: "theme-color", content: "#ff0000" } },
              { tag_name: "meta", attributes: { name: "msapplication-TileColor", content: "#ff0000" } },
              { tag_name: "meta", attributes: { name: "application-name", content: "XXX" } },
            ]
          end
        end
      end
    end
  end
end
