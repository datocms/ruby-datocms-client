# frozen_string_literal: true
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

Dir['spec/support/**/*.rb'].each { |f| require_relative '../' + f }

require 'vcr'
require 'i18n'
require 'i18n/backend/fallbacks'

I18n.enforce_available_locales = false
I18n.available_locales = [:it, :en, :ru]
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
  config.default_cassette_options = {
    match_requests_on: [:method, :uri, :query, :body]
  }
end

VCR.use_cassette('json_schema', record: :new_episodes) do
  require 'dato'
end
