# frozen_string_literal: true

require 'spec_helper'

describe Dato::Local::Loader, :vcr do
  include_context 'with a new site'

  subject(:loader) do
    described_class.new(client, true)
  end

  it 'fetches an entire site' do
    loader.load
    repo = loader.items_repo

    expect(repo.articles.size).to eq 1
    expect(repo.articles.first.title).to eq 'First post'
    expect(repo.articles.first.image.format).to eq 'png'
    expect(repo.articles.first.file.format).to eq 'txt'
  end
end
