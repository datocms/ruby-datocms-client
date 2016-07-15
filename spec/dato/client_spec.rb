require 'spec_helper'

module Dato
  describe Client do
    subject(:client) do
      described_class.new('ce1b55da071c8639b78423a5cb08222c9b03d3a52fa95d37a4')
    end

    it 'foo' do
      puts client.site.find
    end
  end
end
