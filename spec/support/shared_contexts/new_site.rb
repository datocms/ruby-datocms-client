RSpec.shared_context 'with a new site' do
  let(:account_client) do
    Dato::Account::Client.new(
      'XXX',
      base_url: 'http://account-api.lvh.me:3001'
    )
  end

  let(:site) do
    account_client.sites.create(
      name: 'Integration new test site',
    )
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
      modular_block: false,
      sortable: false,
      tree: false,
      api_key: 'article',
      ordering_direction: nil,
      ordering_field: nil
    )
  end

  let(:text_field) do
    client.fields.create(
      item_type[:id],
      api_key: 'title',
      field_type: 'string',
      appeareance: { type: 'title' },
      label: 'Title',
      localized: true,
      position: 99,
      hint: '',
      validators: { required: {} }
    )
  end

  let(:slug_field) do
    client.fields.create(
      item_type[:id],
      api_key: 'slug',
      field_type: 'slug',
      appeareance: {
        title_field_id: text_field[:id].to_s,
        url_prefix: nil
      },
      label: 'Slug',
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
      title: {
        en: 'First post',
        it: 'Primo post'
      },
      slug: 'first-post',
      image: client.upload_image('https://www.datocms.com/static/2-00c287793580e47fbe1222a1d44a6e25-95c66.png'),
      file: client.upload_file('./spec/fixtures/file.txt')
    )
  end

  before do
    site

    client.site.update(client.site.find.merge(locales: ['en', 'it']))

    item_type
    text_field
    slug_field
    image_field
    file_field
    item

    client.items.publish(item[:id])
  end

  after do
    account_client.sites.destroy(site[:id])
  end
end
