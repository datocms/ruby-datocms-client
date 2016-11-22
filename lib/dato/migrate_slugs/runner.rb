# frozen_string_literal: true
require 'dato/json_api_deserializer'
require 'active_support/inflector/transliterate'

module Dato
  module MigrateSlugs
    class Runner
      attr_reader :client, :skip_id_prefix

      def initialize(client, skip_id_prefix)
        @client = client
        @skip_id_prefix = skip_id_prefix
      end

      def run
        print 'Fetching site informations... '
        title_fields
        puts "\e[32m✓\e[0m"

        title_fields.each do |title_field|
          item_type = item_types.find do |i|
            i['id'] == title_field['item_type']
          end

          print "Adding slug field to Item type `#{item_type['name']}`... "
          add_slug_field(title_field)
          puts "\e[32m✓\e[0m"

          items = items_for(title_field['item_type'])
          print "Generating slugs for #{items.count} items"

          items.each do |item|
            update_item(title_field, item)
            print '.'
          end
          puts "\e[32m✓\e[0m"

          puts
        end
      end

      def simple_slugify(item, title, suffix)
        return nil unless title

        slug = title.parameterize[0..50].gsub(/(^\-|\-$)/, '')
        skip_id_prefix ? "#{slug}#{suffix}" : "#{item['id']}-#{slug}#{suffix}"
      end

      def slugify(item, title, suffix)
        if title.is_a?(Hash)
          Hash[
            title.map do |locale, value|
              [locale, simple_slugify(item, value, suffix)]
            end
          ]
        else
          simple_slugify(item, title, suffix)
        end
      end

      def update_item(title_field, item)
        title = item[title_field['api_key']]
        counter = 0

        loop do
          begin
            slug = slugify(item, title, counter.zero? ? '' : "-#{counter}")
            return client.items.update(item['id'], item.merge(slug: slug))
          rescue ApiError => e
            error = e.body['data'][0]

            if error['id'] == 'INVALID_FIELD' &&
               error['attributes']['details']['field'] == 'slug' &&
               error['attributes']['details']['code'] == 'VALIDATION_UNIQUE'

              counter += 1
            else
              raise e
            end
          end
        end
      end

      def items_for(item_type_id)
        items_per_page = 500
        base_response = client.request(
          :get,
          '/items',
          'page[limit]' => 500,
          'filter[type]' => item_type_id
        )

        extra_pages = (
          base_response[:meta][:total_count] / items_per_page.to_f
        ).ceil - 1

        extra_pages.times do |page|
          base_response[:data] += client.request(
            :get,
            '/items',
            'page[offset]' => items_per_page * (page + 1),
            'page[limit]' => items_per_page
          )[:data]
        end

        JsonApiDeserializer.new.deserialize(base_response)
      end

      def add_slug_field(field)
        validators = {
          unique: {}
        }

        validators[:required] = {} if field['validators']['required']

        slug_field = client.fields.create(
          field['item_type'],
          field_type: 'slug',
          appeareance: { title_field_id: field['id'] },
          validators: validators,
          position: 99,
          api_key: 'slug',
          label: 'Slug',
          hint: '',
          localized: field['localized']
        )

        client.fields.update(
          slug_field['id'],
          position: field['position'] + 1
        )
      end

      def title_fields
        @title_fields ||= item_types.map do |item_type|
          fields = client.fields.all(item_type['id'])

          any_slug_present = fields.any? do |f|
            f['field_type'] == 'slug' || f['api_key'] == 'slug'
          end

          next if any_slug_present
          fields.find do |field|
            field['field_type'] == 'string' &&
              field['appeareance']['type'] == 'title'
          end
        end.compact
      end

      def item_types
        @item_types ||= client.item_types.all
      end
    end
  end
end
