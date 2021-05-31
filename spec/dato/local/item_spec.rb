# frozen_string_literal: true

require "spec_helper"

module Dato
  module Local
    RSpec.describe Item do
      subject(:item) do
        ItemsRepo.new(entities_repo).work_items.first
      end

      let(:entity) do
        entities_repo.find_entities_of_type("item").first
      end

      let(:entities_repo) do
        EntitiesRepo.new(entities)
      end

      let(:repo) do
        ItemsRepo.new(entities_repo)
      end

      let(:entities) do
        {
          data: [
            {
              id: "item",
              type: "item",
              attributes: item_attributes,
              meta: {
                updated_at: "2010-01-01T00:00",
              },
              relationships: {
                item_type: {
                  data: {
                    id: "item-type",
                    type: "item_type",
                  },
                },
              },
            },
            {
              id: "item-type",
              type: "item_type",
              attributes: {
                singleton: is_singleton,
                modular_block: false,
                sortable: true,
                api_key: "work_item",
              },
              relationships: {
                fields: {
                  data: [
                    { id: "title", type: "field" },
                    { id: "body", type: "field" },
                  ],
                },
              },
            },
            {
              id: "title",
              type: "field",
              attributes: {
                position: 1,
                api_key: title_api_key,
                localized: title_localized,
                field_type: title_field_type,
                appearance: {
                  addons: [],
                  editor: "single_line",
                  parameters: { heading: true },
                },
              },
            },
            {
              id: "body",
              type: "field",
              attributes: {
                position: 2,
                api_key: "body",
                localized: false,
                field_type: "text",
                appearance: {
                  addons: [],
                  editor: "markdown",
                  parameters: { toolbar: ["bold"] },
                },
              },
            },
          ],
        }
      end

      let(:is_singleton) { false }
      let(:title_localized) { false }
      let(:title_field_type) { "string" }
      let(:title_api_key) { "title" }

      let(:item_attributes) do
        {
          title_api_key.to_sym => "My titlè with àccents",
          body: "Hi there",
          position: 2,
        }
      end

      describe "#attributes" do
        it "returns an hash of the field values" do
          expected_attributes = {
            "title" => "My titlè with àccents",
            "body" => "Hi there",
          }
          expect(item.attributes).to eq expected_attributes
        end
      end

      describe "position" do
        it "returns the entity position field" do
          expect(item.position).to eq 2
        end
      end

      describe "updated_at" do
        it "returns the entity updated_at field" do
          expect(item.updated_at).to be_a Time
        end
      end

      describe "dynamic methods" do
        context "existing field" do
          it "returns the field value" do
            expect(item.respond_to?(:body)).to be_truthy
            expect(item.body).to eq "Hi there"
            expect(item[:body]).to eq "Hi there"
            expect(item["body"]).to eq "Hi there"
          end

          context "localized field" do
            let(:item_attributes) do
              super().merge(title: { it: "Foo", en: "Bar" })
            end

            let(:title_localized) { true }

            it "returns the value for the current locale" do
              I18n.with_locale(:it) do
                expect(item.title).to eq "Foo"
              end
            end

            context "non existing value" do
              it "raises nil" do
                I18n.with_locale(:ru) do
                  expect(item.title).to eq nil
                end
              end
            end

            context "fallbacks" do
              let(:item_attributes) do
                super().merge(title: { ru: nil, "es-ES": "Bar" })
              end

              it "uses them" do
                I18n.with_locale(:ru) do
                  expect(item.title).to eq "Bar"
                end
              end
            end
          end
        end

        context "non existing field" do
          it "raises NoMethodError" do
            expect(item.respond_to?(:qux)).to be_falsy
            expect { item.qux }.to raise_error NoMethodError
          end
        end

        context "non existing field type" do
          let(:title_field_type) { "rotfl" }

          it "returns the raw item value" do
            expect(item.title).to eq "My titlè with àccents"
          end
        end

        context "field with api_key = meta" do
          let(:title_api_key) { "meta" }

          it ".meta returns the meta info" do
            expect(item.meta).to be_a JsonApiMeta
            expect(item["meta"]).to eq "My titlè with àccents"
            expect(item[:meta]).to eq "My titlè with àccents"
          end
        end
      end

      context "meta" do
        it "returns raw info" do
          expect(item.meta.updated_at).to eq "2010-01-01T00:00"
        end
      end

      context "equality" do
        subject(:same_item) { described_class.new(entity, repo) }

        subject(:another_item) { described_class.new(another_entity, repo) }
        let(:another_entity) do
          double(
            "Dato::Local::JsonApiEntity(Item)",
            id: "15",
          )
        end

        it "two items are equal if their id is the same" do
          expect(item).to eq same_item
        end

        it "else they're not" do
          expect(item).not_to eq another_item
          expect(item).not_to eq "foobar"
        end
      end
    end
  end
end
