require "bundler/gem_tasks"
require "rspec/core/rake_task"

require_relative "./build/download_schema"
require_relative "./build/build_client"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :build_repos do
  downloader = DownloadSchema.new("y32upcTKLupUjXiC9nFW", "182")

  BuildClient.new(
    downloader.schema("backend-hyperschema.json"),
    "site",
    %w(session item)
  ).build

  BuildClient.new(
    downloader.schema("frontend-hyperschema.json"),
    "account",
    %w(session item)
  ).build
end
