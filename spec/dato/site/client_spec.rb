# frozen_string_literal: true
require 'spec_helper'

module Dato
  module Site
    describe Client, :vcr do
      let(:account_client) do
        Dato::Account::Client.new(
          'XXX',
          base_url: 'http://account-api.lvh.me:3001',
          extra_headers: { 'X-Foo' => 'Bar' }
        )
      end

      let(:site) do
        account_client.sites.create(name: 'Test site')
      end

      subject(:client) do
        Dato::Site::Client.new(
          site[:readwrite_token],
          base_url: 'http://site-api.lvh.me:3001'
        )
      end

      before { site }
      after { account_client.sites.destroy(site[:id]) }

      describe 'Not found' do
        it 'raises Dato::ApiError' do
          expect { client.item_types.find(44) }.to raise_error Dato::ApiError
        end
      end

      describe 'Menu items' do
        let(:item_type) do
          client.item_types.create(
            name: 'Article',
            singleton: false,
            sortable: false,
            tree: false,
            api_key: 'article',
            ordering_direction: nil,
            ordering_field: nil
          )
        end

        let(:parent_menu_item) do
          client.menu_items.create(
            label: 'Parent',
            position: 99,
            item_type: nil
          )
        end

        it 'fetch, create, update and destroy' do
          new_menu_item = client.menu_items.create(
            label: 'Articles',
            position: 99,
            parent: parent_menu_item[:id],
            item_type: item_type[:id]
          )

          client.menu_items.update(
            new_menu_item[:id],
            new_menu_item.merge(label: 'Manage articles')
          )

          expect(client.menu_items.all.size).to eq 3
          expect(client.menu_items.find(new_menu_item[:id])[:label]).to eq 'Manage articles'

          client.menu_items.destroy(new_menu_item[:id])
          expect(client.menu_items.all.size).to eq 2
        end
      end

      describe 'Item types' do
        it 'fetch, create, update and destroy' do
          new_item_type = client.item_types.create(
            name: 'Article',
            singleton: false,
            sortable: false,
            tree: false,
            api_key: 'article',
            ordering_direction: nil,
            ordering_field: nil
          )

          expect(client.item_types.all.size).to eq 1

          client.item_types.update(
            new_item_type[:id],
            new_item_type.merge(name: 'Post', api_key: 'post')
          )

          expect(client.item_types.find(new_item_type[:id])[:api_key]).to eq 'post'

          duplicate = client.item_types.duplicate(
            new_item_type[:id]
          )

          expect(client.item_types.find(duplicate[:id])[:api_key]).to eq 'post_copy_1'

          client.item_types.destroy(new_item_type[:id])

          expect(client.item_types.all.size).to eq 1
        end
      end

      describe 'Fields' do
        let(:item_type) do
          client.item_types.create(
            name: 'Article',
            singleton: false,
            sortable: false,
            tree: false,
            api_key: 'article',
            ordering_direction: nil,
            ordering_field: nil

          )
        end

        it 'fetch, create, update and destroy' do
          new_field = client.fields.create(
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

          expect(client.fields.all(item_type[:id]).size).to eq 1

          client.fields.update(
            new_field[:id],
            new_field.merge(label: 'Article title')
          )

          expect(client.fields.find(new_field[:id])[:label]).to eq 'Article title'

          client.fields.destroy(new_field[:id])
          expect(client.fields.all(item_type[:id]).size).to eq 0
        end
      end

      describe 'Items' do
        let(:item_type) do
          client.item_types.create(
            name: 'Article',
            singleton: false,
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

        before do
          text_field
          image_field
          file_field
        end

        it 'fetch, create, update and destroy' do
          new_item = client.items.create(
            item_type: item_type[:id],
            title: 'First post',
            image: client.upload_image('https://www.datocms.com/images/logo.png'),
            file: client.upload_file('./spec/fixtures/file.txt')
          )

          expect(client.items.all('filter[type]' => item_type[:id]).size).to eq 1

          client.items.update(
            new_item[:id],
            new_item.merge(title: 'Welcome!')
          )

          expect(client.items.find(new_item[:id])[:title]).to eq 'Welcome!'

          client.items.destroy(new_item[:id])
          expect(client.items.all('filter[type]' => item_type[:id]).size).to eq 0
        end
      end

      describe 'Users' do
        it 'fetch, create and destroy' do
          role = client.roles.all.first

          user = client.users.create(
            email: 'foo@bar.it',
            first_name: 'Foo',
            last_name: 'Bar',
            role: role[:id]
          )

          expect(client.users.all.size).to eq 1

          fetched_user = client.users.find(user[:id])
          expect(fetched_user[:first_name]).to eq 'Foo'

          client.users.destroy(user[:id])
        end
      end

      describe 'Site' do
        it 'fetch, update' do
          site = client.site.find
          client.site.update(site.merge(name: 'My Blog'))
          expect(client.site.find[:name]).to eq 'My Blog'
        end
      end
    end
  end
end
