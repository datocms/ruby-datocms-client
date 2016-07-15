require 'erb'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/indent'

require_relative "./build_method"

class BuildResource
  attr_reader :resource, :schema

  def initialize(resource, schema)
    @resource = resource
    @schema = schema
  end

  def build
    File.open("./lib/dato/repo/#{resource}.rb", "w") do |file|
      file.write content
    end
  end

  def content
    ERB.new(template, nil, '-').result(binding)
  end

  def template
    File.read("./build/templates/resource.rb.erb")
  end

  def class_name
    resource.classify
  end

  def methods
    schema.links.map do |link|
      BuildMethod.new(resource, link)
    end
  end

  def links
    schema.links
  end
end
