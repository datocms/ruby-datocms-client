# frozen_string_literal: true

module Dato
  module Local
    module FieldType
      class StructuredText
        def self.parse(value, repo)
          new(value, repo)
        end

        def initialize(value, repo)
          @value = value
          @repo = repo
        end

        def value
          @value
        end

        def blocks
          find_all_nodes("block").map do |node|
            @repo.find(node["item"])
          end.uniq
        end

        def links
          find_all_nodes(["inlineItem", "itemLink"]).map do |node|
            @repo.find(node["item"])
          end.uniq
        end

        def find_all_nodes(types)
          if value.nil?
            return []
          end

          types = Array(types)
          result = []

          visit(value["document"]) do |node|
            if node.is_a?(Hash) && types.include?(node["type"])
              result << node
            end
          end

          result
        end

        def visit(node, &block)
          if node.is_a?(Hash) && node["children"].is_a?(Array)
            node["children"].each do |child|
              visit(child, &block)
            end
          end

          block.call(node)
        end

        def to_hash(max_depth = 3, current_depth = 0)
          {
            value: value,
            links: links.map { |item| item.to_hash(max_depth, current_depth) },
            blocks: blocks.map { |item| item.to_hash(max_depth, current_depth) },
          }
        end
      end
    end
  end
end
