require "json"
require "json_schema"
require_relative "./build_resource"

class BuildClient
  BLACKLISTED_RESOURCES = %w(session item)

  attr_reader :schema

  def initialize(schema)
    @schema = JsonSchema.parse!(JSON.parse(schema))
    @schema.expand_references!
  end

  def build
    schema.properties.each do |resource, resource_schema|
      if !BLACKLISTED_RESOURCES.include?(resource) && resource_schema.links.any?
        puts resource
        BuildResource.new(resource, resource_schema).build
      end
    end
  end
end
