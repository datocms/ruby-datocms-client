# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Local
    RSpec.describe ItemsRepo do
      subject(:repo) { described_class.new(entities_repo) }
      let(:entities_repo) do
        instance_double('Dato::Local::EntitiesRepo')
      end
      let(:item_type) do
        double(
          'Dato::Local::JsonApiEntity',
          api_key: 'post',
          singleton: false,
          modular_block: false,
          sortable: false,
          ordering_field: nil,
          ordering_direction: nil
        )
      end
      let(:singleton_item_type) do
        double(
          'Dato::Local::JsonApiEntity',
          api_key: 'homepage',
          singleton: true,
          modular_block: false,
          ordering_field: nil,
          ordering_direction: nil
        )
      end
      let(:item_entity) do
        double('Dato::Local::JsonApiEntity', item_type: item_type)
      end
      let(:item_2_entity) do
        double('Dato::Local::JsonApiEntity', item_type: item_type)
      end
      let(:singleton_item_entity) do
        double('Dato::Local::JsonApiEntity', item_type: singleton_item_type)
      end
      let(:item) do
        instance_double('Dato::Local::Item', id: '14')
      end
      let(:item_2) do
        instance_double('Dato::Local::Item', id: '15', position: 1)
      end
      let(:singleton_item) do
        instance_double('Dato::Local::Item', id: '22')
      end

      before do
        allow(singleton_item_type).to receive(:singleton_item) { singleton_item }

        allow(entities_repo).to receive(:find_entities_of_type).with('item_type') do
          [item_type, singleton_item_type]
        end

        allow(entities_repo).to receive(:find_entities_of_type).with('item') do
          [item_entity, item_2_entity, singleton_item_entity]
        end

        allow(Item).to receive(:new).with(item_entity, anything) do
          item
        end

        allow(Item).to receive(:new).with(item_2_entity, anything) do
          item_2
        end

        allow(Item).to receive(:new).with(singleton_item_entity, anything) do
          singleton_item
        end
      end

      describe '#find' do
        it 'returns the specified item' do
          expect(repo.find('14')).to eq item
          expect(repo.find('22')).to eq singleton_item
        end
      end

      describe 'item_types' do
        describe 'singleton' do
          it 'returns the associated item' do
            expect(repo.respond_to?(:homepage)).to be_truthy
            expect(repo.homepage).to eq singleton_item
          end
        end

        describe 'non-singleton' do
          it 'returns the associated items' do
            expect(repo.respond_to?(:posts)).to be_truthy
            expect(repo.posts).to eq [item, item_2]
          end
        end

        describe 'non existing content types' do
          it 'returns NoMethodError' do
            expect(repo.respond_to?(:foobars)).to be_falsy
            expect { repo.foobars }.to raise_error NoMethodError
          end
        end

        describe 'non-singleton that clashes with singleton' do
          let(:item_type) do
            double(
              'Dato::Local::JsonApiEntity',
              api_key: 'post',
              singleton: false,
              modular_block: false,
              sortable: false,
              ordering_field: nil,
              ordering_direction: nil
            )
          end

          let(:singleton_item_type) do
            double(
              'Dato::Local::JsonApiEntity',
              api_key: 'posts',
              singleton: true,
              modular_block: false,
              ordering_field: nil,
              ordering_direction: nil
            )
          end

          it 'responds to XXX_instance and XXX_collection method' do
            expect(repo.posts_collection).to eq [item, item_2]
            expect(repo.posts_instance).to eq singleton_item
          end
        end

        describe 'singleton that clashes with non-singleton' do
          let(:item_type) do
            double(
              'Dato::Local::JsonApiEntity',
              api_key: 'posts',
              singleton: false,
              modular_block: false,
              sortable: false,
              ordering_field: nil,
              ordering_direction: nil
            )
          end

          let(:singleton_item_type) do
            double(
              'Dato::Local::JsonApiEntity',
              api_key: 'posts',
              singleton: true,
              modular_block: false,
              ordering_field: nil,
              ordering_direction: nil
            )
          end

          it 'responds to XXX_instance and XXX_collection method' do
            expect(repo.posts_collection).to eq [item, item_2]
            expect(repo.posts_instance).to eq singleton_item
          end
        end

        describe 'sortable collection' do
          let(:item_type) do
            double(
              'Dato::Local::JsonApiEntity',
              api_key: 'post',
              singleton: false,
              sortable: true,
              modular_block: false
            )
          end
          let(:item) do
            instance_double('Dato::Local::Item', id: '14', position: 2)
          end
          let(:item_2) do
            instance_double('Dato::Local::Item', id: '15', position: 1)
          end

          it 'sorts items by position' do
            expect(repo.posts).to eq [item_2, item]
          end
        end
      end

      describe ItemsRepo::ItemCollection do
        subject(:collection) { described_class.new(items) }
        let(:items) do
          [foo]
        end

        let(:foo) { double('Dato::Local::Item', id: '1', name: 'Foo') }

        describe '#[]' do
          it 'returns the item with the specified id or index' do
            expect(collection['1']).to eq foo
            expect(collection[0]).to eq foo
          end
        end

        describe '#keys' do
          it 'returns the list of ids' do
            expect(collection.keys).to eq ['1']
          end
        end

        describe '#each' do
          context 'with arity == 2' do
            it 'iterates with id and item' do
              collection.each do |a, b|
                expect(a).to eq '1'
                expect(b).to eq foo
              end
            end
          end

          context 'with arity != 2' do
            it 'iterates just like a regular array' do
              collection.each do |a|
                expect(a).to eq foo
              end
            end
          end
        end

        it '#values' do
          expect(collection.values).to eq [foo]
        end

        it '#sort_by' do
          expect(collection.sort_by(&:name)).to eq [foo]
        end
      end
    end
  end
end
