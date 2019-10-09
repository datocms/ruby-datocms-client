# frozen_string_literal: true

require "spec_helper"

module Dato
  module Local
    module FieldType
      RSpec.describe Dato::Local::FieldType::File do
        subject(:file) { described_class.parse(attributes, repo) }

        let(:repo) { instance_double("Dato::Local::ItemsRepo", site: site, entities_repo: entities_repo) }
        let(:site) { instance_double("Dato::Local::Site", entity: site_entity) }
        let(:site_entity) { double("Dato::Local::JsonApiEntity", imgix_host: "foobar.com") }
        let(:entities_repo) { instance_double("Dato::Local::EntitiesRepo", find_entity: upload_entity) }
        let(:upload_entity) { double("Dato::Local::JsonApiEntity", upload_attributes) }

        context "with alt title" do
          let(:attributes) do
            {
              upload_id: upload_entity.id,
              alt: "an alt",
              title: "a title",
              custom_data: { hello: "world" }
            }
          end

          let(:upload_attributes) do
            {
              id: "333",
              path: "/foo.png",
              format: "jpg",
              size: 4000,
              width: 20,
              height: 20,
              default_field_metadata: {
                en: {
                  alt: nil,
                  title: nil,
                  custom_data: {}
                }
              }
            }
          end

          it "responds to path, format and size methods" do
            expect(file.path).to eq "/foo.png"
            expect(file.format).to eq "jpg"
            expect(file.size).to eq 4000
            expect(file.width).to eq 20
            expect(file.height).to eq 20
            expect(file.alt).to eq "an alt"
            expect(file.title).to eq "a title"
            expect(file.custom_data).to eq ({ "hello"=>"world" })
          end

          it "responds to url method" do
            expect(file.url(w: 300)).to eq "https://foobar.com/foo.png?w=300"
          end
        end

        context "with no alt title" do
          let(:attributes) do
            {
              upload_id: upload_entity.id,
              alt: nil,
              title: nil,
              custom_data: {}
            }
          end

          let(:upload_attributes) do
            {
              id: "333",
              path: "/foo.png",
              format: "jpg",
              size: 4000,
              width: 20,
              height: 20,
              author: "author",
              notes: "notes",
              copyright: "copyright",
              default_field_metadata: {
                en: {
                  alt: "Default alt",
                  title: "Default title",
                  custom_data: { hello: "world" }
                }
              }
            }
          end

          it "folds to default" do
            expect(file.author).to eq "author"
            expect(file.notes).to eq "notes"
            expect(file.copyright).to eq "copyright"
            expect(file.alt).to eq "Default alt"
            expect(file.title).to eq "Default title"
            expect(file.custom_data).to eq ({ "hello"=>"world" })
          end
        end

        context "with locale not set" do
          let(:site_entity) { double("Dato::Local::JsonApiEntity", imgix_host: "foobar.com", locales: [:it]) }

          context "with alt title" do
            let(:attributes) do
              {
                upload_id: upload_entity.id,
                alt: nil,
                title: nil,
                custom_data: {}
              }
            end

            let(:upload_attributes) do
              {
                id: "333",
                path: "/foo.png",
                format: "jpg",
                size: 4000,
                width: 20,
                height: 20,
                default_field_metadata: {
                  it: {
                    alt: "alt italiano",
                    title: "title italiano",
                    custom_data: {}
                  }
                }
              }
            end

            it "set title and alt to nul" do
              expect(file.alt).to be nil
              expect(file.title).to be nil
              expect(file.custom_data).to eq ({})
            end
          end
        end
      end
    end
  end
end
