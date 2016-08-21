# frozen_string_literal: true
require 'spec_helper'

describe Dato::Local::Site, :vcr do
  let(:account_client) do
    Dato::Account::Client.new(
      'XXXYYY',
      base_url: 'http://account-api.lvh.me:3001'
    )
  end

  let(:site) do
    account_client.sites.create(name: 'Test site')
  end

  let(:client) do
    Dato::Site::Client.new(
      site[:readwrite_token],
      base_url: 'http://site-api.lvh.me:3001'
    )
  end

  let(:item_type) do
    client.item_types.create(
      name: 'Article',
      singleton: false,
      sortable: false,
      api_key: 'article'
    )
  end

  let(:text_field) do
    client.fields.create(
      item_type[:id],
      api_key: 'title',
      field_type: 'string',
      appeareance: { type: 'title' },
      label: 'Title',
      localized: false,
      position: 99,
      hint: '',
      validators: { required: {} }
    )
  end

  let(:image_field) do
    client.fields.create(
      item_type[:id],
      api_key: 'image',
      field_type: 'image',
      appeareance: nil,
      label: 'Image',
      localized: false,
      position: 99,
      hint: '',
      validators: { required: {} }
    )
  end

  let(:file_field) do
    client.fields.create(
      item_type[:id],
      api_key: 'file',
      field_type: 'file',
      appeareance: nil,
      label: 'File',
      localized: false,
      position: 99,
      hint: '',
      validators: { required: {} }
    )
  end

  let(:item) do
    client.items.create(
      item_type: item_type[:id],
      title: 'First post',
      image: client.upload_image('https://www.datocms.com/icons/apple-touch-icon-57x57.png'),
      file: client.upload_file('./spec/fixtures/file.txt')
    )
  end

  subject(:local_site) do
    described_class.new(client)
  end

  before do
    site
    item_type
    text_field
    image_field
    file_field
    item
    local_site.load
  end

  after do
    account_client.sites.destroy(site[:id])
  end

  it 'fetches an entire site' do
    repo = local_site.items_repo
    expect(repo.articles.size).to eq 1
    expect(repo.articles.first.title).to eq 'First post'
    expect(repo.articles.first.image.format).to eq 'png'
    expect(repo.articles.first.file.format).to eq 'txt'
  end
end
