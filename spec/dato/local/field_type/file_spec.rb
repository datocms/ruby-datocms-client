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

        context "when uploading a video" do
          let(:attributes) do
            {
              upload_id: upload_entity.id,
              alt: nil,
              title: nil,
              custom_data: {},
            }
          end

          let(:upload_attributes) do
            {
              id: "333",
              path: "/foo.mp4",
              format: "mp4",
              mux_playback_id: "444",
              duration: 300,
              frame_rate: 50,
              mux_mp4_highest_res: "medium",
            }
          end

          it "responds outputs video info" do
            expect(file.video.duration).to eq(300)
            expect(file.video.frame_rate).to eq(50)
            expect(file.video.mux_playback_id).to eq("444")
            expect(file.video.thumbnail_url(:gif)).to eq("https://image.mux.com/444/animated.gif")
            expect(file.video.streaming_url).to eq("https://stream.mux.com/444.m3u8")
            expect(file.video.thumbnail_url).to eq("https://image.mux.com/444/thumbnail.jpg")
            expect(file.video.mp4_url).to eq("https://stream.mux.com/444/medium.mp4")
            expect(file.video.mp4_url(exact_res: :high)).to be_nil
            expect(file.video.mp4_url(exact_res: :low)).to eq("https://stream.mux.com/444/low.mp4")
          end
        end

        context "with image attributes" do
          let(:attributes) do
            {
              upload_id: upload_entity.id,
              alt: "an alt",
              title: nil,
              custom_data: { hello: "world" },
              focal_point: { x: 0.3, y: 0.4 },
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
              tags: ["ciao"],
              colors: [{ red: 255, green: 255, blue: 255, alpha: 255 }],
              video: nil,
              default_field_metadata: {
                en: {
                  alt: nil,
                  title: "a title",
                  custom_data: {},
                  focal_point: { x: 0.3, y: 0.4 },
                },
              },
            }
          end

          it "responds to all images methods" do
            expect(file).to match an_object_having_attributes(
              path: "/foo.png",
              format: "jpg",
              size: 4000,
              width: 20,
              height: 20,
              alt: "an alt",
              title: "a title",
              custom_data: a_hash_including(hello: "world"),
              tags: ["ciao"],
              colors: include(
                an_object_having_attributes(
                  alpha: 1.0,
                  red: 255,
                  green: 255,
                  blue: 255,
                  hex: "#ffffff",
                ),
              ),
            )
          end

          it "responds to url method" do
            expect(file.url(w: 300)).to eq "https://foobar.com/foo.png?w=300"
          end

          it "returns focal point" do
            expect(file.url(w: 300, h: 300, fit: "crop")).to eq "https://foobar.com/foo.png?w=300&h=300&fit=crop&crop=focalpoint&fp-x=0.3&fp-y=0.4"
            expect(file.url(w: 300, h: 300, fit: "crop")).to eq "https://foobar.com/foo.png?w=300&h=300&fit=crop&crop=focalpoint&fp-x=0.3&fp-y=0.4"
          end

          describe "#lqip_data_url" do
            context "host != www.datocms-assets.com" do
              it "raises an error" do
                expect { file.lqip_data_url }.to raise_error(RuntimeError)
              end
            end

            context "www.datocms-assets.com" do
              let(:site_entity) { double("Dato::Local::JsonApiEntity", imgix_host: "www.datocms-assets.com") }

              before do
                VCR.turn_off!
              end

              after do
                VCR.turn_on!
              end

              context "status = 200" do
                before do
                  stub_request(:get, "https://www.datocms-assets.com/foo.png?lqip=blurhash&w=300")
                    .to_return(body: ::File.new("./spec/fixtures/blurhash.jpg"))
                end

                it "returns base64-encoded url" do
                  expect(file.lqip_data_url(w: 300)).to eq "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAoHBwgHBgoICAgXFQoLDhUSDhUXDh0eDRUVGRYZGBYTFhUaIi0jGh0oHRUWJDUlKC0vMjIyGSI4PTcwPCsxMi8BCgsLDg0OHBAQHDsoIig7Lzs7Ozs7Ozs7LzsvLy8vLy8vLzsvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vL//AABEIAA0AGAMBIgACEQEDEQH/xAAYAAEAAwEAAAAAAAAAAAAAAAAAAwQFAv/EABwQAAAHAQEAAAAAAAAAAAAAAAABAgMEBRESQf/EABUBAQEAAAAAAAAAAAAAAAAAAAMB/8QAHREAAQMFAQAAAAAAAAAAAAAAAQAREgITITFCA//aAAwDAQACEQMRAD8AqPMJiF1o6jvlILkhlWU11aMMTU6j50UPHKcCmTJa1aXEnvoBdy3GmTNPgAwfTkpbNJ2F/9k="
                end
              end

              context "status != 200" do
                before do
                  stub_request(:get, "https://www.datocms-assets.com/foo.png?lqip=blurhash&w=300")
                    .to_return(status: 422)
                end

                it "returns nil" do
                  expect(file.lqip_data_url(w: 300)).to be_nil
                end
              end
            end
          end
        end

        context "with no alt title" do
          let(:attributes) do
            {
              upload_id: upload_entity.id,
              alt: nil,
              title: nil,
              custom_data: {},
              focal_point: nil,
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
                  custom_data: { hello: "world" },
                  focal_point: { x: 0.1, y: 0.2 },
                },
              },
            }
          end

          it "folds to default" do
            expect(file.author).to eq "author"
            expect(file.notes).to eq "notes"
            expect(file.copyright).to eq "copyright"
            expect(file.alt).to eq "Default alt"
            expect(file.title).to eq "Default title"
            expect(file.custom_data).to eq({ "hello" => "world" })
            expect(file.focal_point).to eq({ "x" => 0.1, "y" => 0.2 })
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
                custom_data: {},
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
                    custom_data: {},
                  },
                },
              }
            end

            it "set title and alt to nul" do
              expect(file.alt).to be nil
              expect(file.title).to be nil
              expect(file.custom_data).to eq({})
            end
          end
        end
      end
    end
  end
end
