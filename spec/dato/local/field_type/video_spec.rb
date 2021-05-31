# frozen_string_literal: true

require "spec_helper"

module Dato
  module Local
    module FieldType
      RSpec.describe Video do
        subject(:video) { described_class.parse(attributes, nil) }
        let(:attributes) do
          {
            url: "https://www.youtube.com/watch?v=oHg5SJYRHA0",
            provider_uid: "oHg5SJYRHA0",
            thumbnail_url: "http://i3.ytimg.com/vi/oHg5SJYRHA0/hqdefault.jpg",
            title: "RickRoll'D",
            provider: "youtube",
            width: 560,
            height: 315,
          }
        end

        it "responds to path, format, size, width and height" do
          expect(video.url).to eq "https://www.youtube.com/watch?v=oHg5SJYRHA0"
          expect(video.provider).to eq "youtube"
          expect(video.provider_uid).to eq "oHg5SJYRHA0"
          expect(video.thumbnail_url).to eq "http://i3.ytimg.com/vi/oHg5SJYRHA0/hqdefault.jpg"
          expect(video.title).to eq "RickRoll'D"
          expect(video.width).to eq 560
          expect(video.height).to eq 315
        end

        describe "iframe_embed" do
          it "returns a iframe embed HTML fragment" do
            expect(video.iframe_embed).to eq '<iframe width="560" height="315" src="//www.youtube.com/embed/oHg5SJYRHA0?rel=0" frameborder="0" allowfullscreen></iframe>'
          end
        end
      end
    end
  end
end
