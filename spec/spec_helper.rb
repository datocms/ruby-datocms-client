# frozen_string_literal: true

require 'simplecov'
require 'coveralls'

ENV["SITE_API_BASE_URL"] ||= "https://site-api.datocms.com"
ENV["ACCOUNT_API_BASE_URL"] ||= "https://account-api.datocms.com"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter,
                                                                 Coveralls::SimpleCov::Formatter
                                                               ])

SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

Dir['spec/support/**/*.rb'].each { |f| require_relative '../' + f }

require 'pry'
require 'vcr'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'webmock/rspec'

I18n.enforce_available_locales = false
I18n.available_locales = %i[it en ru]
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.fallbacks[:ru] = [:"es-ES"]

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == 'ASCII-8BIT' ||
      !http_message.body.valid_encoding?
  end
  config.configure_rspec_metadata!

  config.register_request_matcher :modified_body do |request1, request2|
    if
        URI(request1.uri).path == '/account' &&
        URI(request2.uri).path == '/account' &&
        request1.method == request2.method

      true
    else
      request1.body == request2.body
    end
  end

  config.default_cassette_options = {
    match_requests_on: %i[method uri query modified_body]
  }
end

VCR.use_cassette('json_schema', record: :new_episodes) do
  require 'dato'
end
