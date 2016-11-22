# frozen_string_literal: true
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'open-uri'

require_relative './build/build_client'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Regenerates the client starting from the JSON Hyperschema'
task :regenerate do
  BuildClient.new(
    open('https://site-api.datocms.com/docs/site-api-hyperschema.json').read,
    'site',
    %w(session item user#update user#destroy)
  ).build

  BuildClient.new(
    open('https://site-api.datocms.com/docs/account-api-hyperschema.json').read,
    'account',
    %w(
      session
      account#create account#reset_password
      subscription
      portal_session
    )
  ).build
end

desc 'Open an irb (or pry) session preloaded with this gem'
task :console do
  begin
    require 'pry'
    gem_name = File.basename(Dir.pwd)
    sh %(pry -I lib -r #{gem_name}.rb)
  rescue LoadError => _
    sh %(irb -rubygems -I lib -r #{gem_name}.rb)
  end
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new
