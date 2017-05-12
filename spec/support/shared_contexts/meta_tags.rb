# frozen_string_literal: true
RSpec.shared_context 'items repo' do
  let(:item) { nil }
  let(:site) { items_repo.site }
  let(:items_repo) { Dato::Local::ItemsRepo.new(entities_repo) }
  let(:entities_repo) { Dato::Local::EntitiesRepo.new(payload) }
  let(:payload) do
    {
      data: [
        {
          id: '24038',
          type: 'item',
          attributes: {
            updated_at: '2016-12-07T09:14:22.046Z',
            is_valid: true,
            title: item_title,
            another_string: 'Foo bar',
            seo_settings: seo,
            image: item_image
          },
          relationships: {
            item_type: {
              data: {
                id: '3781',
                type: 'item_type'
              }
            }
          }
        },
        {
          id: '681',
          type: 'site',
          attributes: {
            name: 'XXX',
            locales: ['en'],
            theme_hue: 190,
            domain: nil,
            internal_domain: 'wispy-sun-3056.admin.datocms.com',
            global_seo: global_seo,
            favicon: favicon,
            no_index: no_index,
            ssg: nil,
            imgix_host: 'www.datocms-assets.com'
          },
          relationships: {
            menu_items: {
              data: [
                {
                  id: '4212',
                  type: 'menu_item'
                }
              ]
            },
            item_types: {
              data: [
                {
                  id: '3781',
                  type: 'item_type'
                }
              ]
            }
          }
        },
        {
          id: '3781',
          type: 'item_type',
          attributes: {
            name: 'Article',
            singleton: false,
            sortable: false,
            api_key: 'article'
          },
          relationships: {
            fields: {
              data: [
                {
                  id: '15088',
                  type: 'field'
                },
                {
                  id: '15085',
                  type: 'field'
                },
                {
                  id: '15086',
                  type: 'field'
                },
                {
                  id: '15087',
                  type: 'field'
                }
              ]
            },
            singleton_item: {
              data: nil
            }
          }
        },
        {
          id: '15088',
          type: 'field',
          attributes: {
            label: 'Image',
            field_type: 'image',
            api_key: 'image',
            hint: nil,
            localized: false,
            validators: {},
            position: 1,
            appeareance: {}
          },
          relationships: {
            item_type: {
              data: {
                id: '3781',
                type: 'item_type'
              }
            }
          }
        },
        {
          id: '15085',
          type: 'field',
          attributes: {
            label: 'Title',
            field_type: 'string',
            api_key: 'title',
            hint: nil,
            localized: false,
            validators: {
              required: {}
            },
            position: 2,
            appeareance: {
              type: 'title'
            }
          },
          relationships: {
            item_type: {
              data: {
                id: '3781',
                type: 'item_type'
              }
            }
          }
        },
        {
          id: '15086',
          type: 'field',
          attributes: {
            label: 'Another string',
            field_type: 'string',
            api_key: 'another_string',
            hint: nil,
            localized: false,
            validators: {},
            position: 3,
            appeareance: {
              type: 'plain'
            }
          },
          relationships: {
            item_type: {
              data: {
                id: '3781',
                type: 'item_type'
              }
            }
          }
        },
        {
          id: '15087',
          type: 'field',
          attributes: {
            label: 'SEO settings',
            field_type: 'seo',
            api_key: 'seo_settings',
            hint: nil,
            localized: false,
            validators: {},
            position: 4,
            appeareance: {}
          },
          relationships: {
            item_type: {
              data: {
                id: '3781',
                type: 'item_type'
              }
            }
          }
        }
      ]
    }
  end
  let(:item_title) { nil }
  let(:item_image) { nil }
  let(:favicon) { nil }
  let(:global_seo) { nil }
  let(:seo) { nil }
  let(:no_index) { false }
  let(:title_suffix) { nil }
end
