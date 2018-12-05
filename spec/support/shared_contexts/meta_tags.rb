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
            is_valid: true,
            title: item_title,
            another_string: 'Foo bar',
            seo_settings: seo,
            image: item_image
          },
          meta: {
            updated_at: '2016-12-07T09:14:22.046Z'
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
          id: '666',
          type: 'upload',
          attributes: {
            path: '/seo.png',
            width: 500,
            height: 500,
            format: 'png',
            size: 572_451,
            alt: 'an alt',
            title: 'a title'
          }
        },
        {
          id: '999',
          type: 'upload',
          attributes: {
            path: '/fallback_seo.png',
            width: 500,
            height: 500,
            format: 'png',
            size: 543_210,
            alt: 'another alt',
            title: 'another title'
          }
        },
        {
          id: '111',
          type: 'upload',
          attributes: {
            path: '/simple_image.png',
            width: 500,
            height: 500,
            format: 'png',
            size: 543_210,
            alt: 'image alt',
            title: 'image title'
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
            modular_block: false,
            draft_mode_active: false,
            sortable: false,
            api_key: 'article',
            ordering_direction: nil
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
            },
            ordering_field: {
              data: nil
            },
            title_field: {
              data: {
                id: '15085',
                type: 'field'
              }
            }
          }
        },
        {
          id: '15088',
          type: 'field',
          attributes: {
            label: 'Image',
            field_type: 'file',
            api_key: 'image',
            hint: nil,
            localized: false,
            validators: {},
            position: 1,
            appeareance: {
              editor: 'file',
              parameters: {}
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
              editor: 'single_line',
              parameters: { heading: true }
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
              editor: 'single_line',
              parameters: { heading: false }
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
            appeareance: {
              editor: 'seo',
              parameters: {}
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
