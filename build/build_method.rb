# frozen_string_literal: true
class BuildMethod
  IDENTITY_REGEXP = /\{\(.*?definitions%2F(.*?)%2Fdefinitions%2Fidentity\)}/

  REL_TO_METHOD = {
    instances: :all,
    self: :find
  }.freeze

  attr_reader :link, :resource

  def initialize(resource, link)
    @link = link
    @resource = resource
  end

  def method_body
    ERB.new(template, nil, '-').result(binding)
  end

  def request_method
    link.method
  end

  def request_url
    link.href.gsub IDENTITY_REGEXP do
      "\#{#{Regexp.last_match(1)}_id}"
    end
  end

  def method_signature
    arguments = url_arguments

    if schema?
      arguments << if get_request?
                     'query'
                   else
                     'resource_attributes'
                   end
    end

    arguments.join(', ')
  end

  def request_argument
    if schema?
      if get_request?
        ', query'
      else
        ', body'
      end
    else
      ''
    end
  end

  def url_arguments
    result = []
    link.href.scan IDENTITY_REGEXP do |_placeholder|
      result << "#{Regexp.last_match(1)}_id"
    end
    result
  end

  def attributes
    if schema_attributes
      schema_attributes.properties.keys
    else
      []
    end
  end

  def required_attributes
    if schema_attributes
      schema_attributes.required || []
    else
      []
    end
  end

  # rubocop:disable Metrics/AbcSize
  def relationships
    return {} unless schema_relationships

    Hash[
      schema_relationships.properties.map do |relationship, schema|
        is_collection = schema.properties['data'].type.first == 'array'

        definition = if is_collection
                       schema.properties['data'].items
                     elsif schema.properties['data'].type.first == 'object'
                       schema.properties['data']
                     else
                       schema.properties['data'].any_of.find do |option|
                         option.type.first == 'object'
                       end
                     end

        type = definition.properties['type']
               .pattern.source.gsub(/(^\^|\$$)/, '')

        [
          relationship.to_sym,
          { collection: is_collection, type: type.to_sym }
        ]
      end
    ]
  end
  # rubocop:enable Metrics/AbcSize

  def required_relationships
    if schema_relationships
      schema_relationships.required || []
    else
      []
    end
  end

  def schema_relationships
    schema? && link.schema.properties['data'].properties['relationships']
  end

  def schema_attributes
    schema? && link.schema.properties['data'].properties['attributes']
  end

  # rubocop:disable Style/AccessorMethodName
  def get_request?
    request_method == :get
  end
  # rubocop:enable Style/AccessorMethodName

  def put_request?
    request_method == :put
  end

  def schema?
    link.schema
  end

  def name
    if REL_TO_METHOD.key?(link.rel.to_sym)
      REL_TO_METHOD[link.rel.to_sym]
    else
      link.rel
    end
  end

  def template
    File.read('./build/templates/method.rb.erb')
  end
end
