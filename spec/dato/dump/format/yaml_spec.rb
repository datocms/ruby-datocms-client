# frozen_string_literal: true

require "spec_helper"

module Dato
  module Dump
    module Format
      RSpec.describe Yaml do
        describe ".dump" do
          it "dumps into Yaml stringifying symbols" do
            expect(Yaml.dump([{ foo: "bar" }])).to eq "- foo: bar"
          end
        end
      end
    end
  end
end
