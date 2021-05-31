# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Site
    describe Client, :vcr do
      let(:account_client) do
        generate_account_client!(extra_headers: { 'X-Foo' => 'Bar' })
      end

      let(:site) do
        account_client.sites.create(name: 'Test site')
      end

      subject(:client) do
        Dato::Site::Client.new(
          site[:readwrite_token],
          base_url: ENV.fetch('SITE_API_BASE_URL')
        )
      end

      before { site }

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
            modular_block: false,
            sortable: false,
            tree: false,
            draft_mode_active: false,
            api_key: 'article',
            ordering_direction: nil,
            ordering_field: nil,
            all_locales_required: true,
            title_field: nil
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
            modular_block: false,
            sortable: false,
            tree: false,
            draft_mode_active: false,
            api_key: 'article',
            ordering_direction: nil,
            ordering_field: nil,
            all_locales_required: true,
            title_field: nil
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

          expect(client.item_types.find(duplicate[:id])[:api_key]).to eq 'post_copy1'

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
            modular_block: false,
            tree: false,
            draft_mode_active: false,
            api_key: 'article',
            ordering_direction: nil,
            ordering_field: nil,
            all_locales_required: true,
            title_field: nil
          )
        end

        it 'fetch, create, update and destroy' do
          new_field = client.fields.create(
            item_type[:id],
            api_key: 'title',
            field_type: 'string',
            label: 'Title',
            validators: { required: {} }
          )

          expect(client.fields.all(item_type[:id]).size).to eq 1

          client.fields.update(
            new_field[:id],
            new_field.merge(
              label: 'Article title',
              appearance: new_field[:appearance].except(:type)
            )
          )

          expect(client.fields.find(new_field[:id])[:label]).to eq 'Article title'

          client.fields.destroy(new_field[:id])
          expect(client.fields.all(item_type[:id]).size).to eq 0
        end
      end

      describe 'Items' do
        describe 'fetch, create, update and destroy' do
          let(:item_type) do
            client.item_types.create(
              name: 'Article',
              singleton: false,
              modular_block: false,
              sortable: false,
              tree: false,
              draft_mode_active: false,
              api_key: 'article',
              ordering_direction: nil,
              ordering_field: nil,
              all_locales_required: true,
              title_field: nil
            )
          end

          let(:text_field) do
            client.fields.create(
              item_type[:id],
              api_key: 'title',
              field_type: 'string',
              label: 'Title',
              validators: { required: {} }
            )
          end

          let(:image_field) do
            client.fields.create(
              item_type[:id],
              api_key: 'image',
              field_type: 'file',
              label: 'Image',
              validators: {
                required: {},
                extension: {
                  predefined_list: 'image'
                }
              }
            )
          end

          let(:file_field) do
            client.fields.create(
              item_type[:id],
              api_key: 'file',
              field_type: 'file',
              label: 'File',
              validators: { required: {} }
            )
          end

          before do
            text_field
            image_field
            file_field
          end

          it 'works' do
            new_item = client.items.create(
              item_type: item_type[:id],
              title: 'First post',
              image: client.upload_image('https://www.datocms-assets.com/205/1549027974-logo.png'),
              file: client.upload_file('./spec/fixtures/file.txt')
            )

            expect(new_item[:item_type]).not_to be_nil

            all_items = client.items.all('filter[type]' => item_type[:id])

            expect(all_items.size).to eq 1
            expect(all_items.first[:item_type]).not_to be_nil

            client.items.update(
              new_item[:id],
              new_item.merge(title: 'Welcome!')
            )

            expect(client.items.find(new_item[:id])[:title]).to eq 'Welcome!'

            client.items.update(
              new_item[:id],
              title: 'Welcome 2!'
            )

            expect(client.items.find(new_item[:id])[:title]).to eq 'Welcome 2!'

            client.items.destroy(new_item[:id])
            expect(client.items.all('filter[type]' => item_type[:id]).size).to eq 0
          end
        end

        describe 'batch actions' do
          let(:item_type) do
            client.item_types.create(
              name: 'Tag',
              singleton: false,
              modular_block: false,
              sortable: false,
              tree: false,
              draft_mode_active: true,
              api_key: 'article',
              ordering_direction: nil,
              ordering_field: nil,
              all_locales_required: true,
              title_field: nil
            )
          end

          let(:text_field) do
            client.fields.create(
              item_type[:id],
              api_key: 'title',
              field_type: 'string',
              label: 'Title',
              validators: { required: {} }
            )
          end

          let(:tag) do
            client.items.create(
              item_type: item_type[:id],
              title: 'Cats'
            )
          end

          let(:tag2) do
            client.items.create(
              item_type: item_type[:id],
              title: 'Dogs'
            )
          end

          before do
            text_field
            tag
            tag2
          end

          it 'works' do
            client.items.batch_publish('filter[ids]' => tag[:id])

            expect(client.items.find(tag[:id])[:meta][:status]).to eq 'published'
            expect(client.items.find(tag2[:id])[:meta][:status]).to eq 'draft'

            client.items.batch_destroy('filter[ids]' => "#{tag[:id]},#{tag2[:id]}")

            expect(client.items.all('filter[type]' => item_type[:id]).size).to eq 0
          end
        end

        describe 'bulk actions' do
          let(:item_type) do
            client.item_types.create(
              name: 'Tag',
              singleton: false,
              modular_block: false,
              sortable: false,
              tree: false,
              draft_mode_active: true,
              api_key: 'article',
              ordering_direction: nil,
              ordering_field: nil,
              all_locales_required: true,
              title_field: nil
            )
          end

          let(:text_field) do
            client.fields.create(
              item_type[:id],
              api_key: 'title',
              field_type: 'string',
              label: 'Title',
              validators: { required: {} }
            )
          end

          let(:tag) do
            client.items.create(
              item_type: item_type[:id],
              title: 'Cats'
            )
          end

          let(:tag2) do
            client.items.create(
              item_type: item_type[:id],
              title: 'Dogs'
            )
          end

          before do
            text_field
            tag
            tag2
          end

          it 'works' do
            client.items.bulk_publish(items: [tag[:id], tag2[:id]])

            expect(client.items.find(tag[:id])[:meta][:status]).to eq 'published'

            client.items.bulk_unpublish(items: [tag[:id], tag2[:id]])

            expect(client.items.find(tag2[:id])[:meta][:status]).to eq 'draft'

            client.items.bulk_destroy(items: [tag[:id], tag2[:id]])
            expect(client.items.all('filter[type]' => item_type[:id]).size).to eq 0
          end
        end
      end

      describe 'Build triggers' do
        it 'create, trigger' do
          env = client.build_triggers.create(
            adapter: 'custom',
            indexing_enabled: false,
            autotrigger_on_scheduled_publications: false,
            adapter_settings: { trigger_url: 'https://www.google.com' },
            frontend_url: nil,
            name: 'Foo'
          )

          expect(client.build_triggers.all.size).to eq 1

          client.build_triggers.trigger(env[:id])
        end
      end

      describe 'Site invitations' do
        it 'fetch, create and destroy' do
          role = client.roles.all.first

          invitation = client.site_invitations.create(
            email: 'foo@bar.it',
            role: role[:id]
          )

          expect(client.site_invitations.all.size).to eq 1
          client.site_invitations.destroy(invitation[:id])
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
