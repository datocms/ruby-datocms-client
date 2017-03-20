# DatoCMS Ruby Client

[![Coverage Status](https://coveralls.io/repos/github/datocms/ruby-datocms-client/badge.svg?branch=master)](https://coveralls.io/github/datocms/ruby-datocms-client?branch=master) [![Build Status](https://travis-ci.org/datocms/ruby-datocms-client.svg?branch=master)](https://travis-ci.org/datocms/ruby-datocms-client) [![Gem Version](https://badge.fury.io/rb/dato.svg)](https://badge.fury.io/rb/dato)

CLI tool for DatoCMS (https://www.datocms.com).

## How to integrate DatoCMS with Jekyll

Please head over the [Jekyll section of our documentation](https://docs.datocms.com/jekyll/overview.html) to learn everything you need to get started.

## How to integrate DatoCMS with Middleman

For Middleman we have created a nice Middleman extension called [middleman-dato](https://github.com/datocms/middleman-dato). Please visit the [Middleman section of our documentation](https://docs.datocms.com/middleman/overview.html) to learn everything you need to get started.

## API Client

This gem also exposes an API client, useful ie. to import existing content in your DatoCMS administrative area. Read our [documentation](https://docs.datocms.com/api-client/ruby.html) for detailed info.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Updating the client when the API changes

The DatoCMS API provides an always up-to-date [JSON Hyperschema](http://json-schema.org/latest/json-schema-hypermedia.html): the code of this gem is generated automatically starting from the schema running `rake regenerate`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/datocms/ruby-datocms-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

