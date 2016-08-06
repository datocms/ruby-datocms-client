require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "open-uri"

require_relative "./build/build_client"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :build_repos do
  BuildClient.new(
    open("https://site-api.datocms.com/docs/site-api-hyperschema.json").read,
    "site",
    %w(session item)
  ).build

  BuildClient.new(
    open("https://site-api.datocms.com/docs/account-api-hyperschema.json").read,
    "account",
    %w(session item)
  ).build
end
