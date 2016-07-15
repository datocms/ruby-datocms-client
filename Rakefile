require "bundler/gem_tasks"
require "rspec/core/rake_task"

require_relative "./build/download_schema"
require_relative "./build/build_client"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :build_resources do
  schema = DownloadSchema.new.schema
  BuildClient.new(schema).build
end
