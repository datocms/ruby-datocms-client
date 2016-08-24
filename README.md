# DatoCMS Ruby Client

[![Build Status](https://travis-ci.org/datocms/ruby-datocms-client.svg?branch=master)](https://travis-ci.org/datocms/ruby-datocms-client) [![Gem Version](https://badge.fury.io/rb/dato.svg)](https://badge.fury.io/rb/dato)

Ruby client for the DatoCMS API.

[DatoCMS](https://www.datocms.com/) is a fully customizable administrative area for your static websites:

1. Use your favorite static website generator (Middleman, Hugo, Jekyll, and many others);
2. Let your clients publish new content independently;
3. Let your site build with any Continuous Deployment service (Netlify, Gitlab, CircleCI, etc.);
4. Host the site anywhere you like (Amazon S3, Netlify, Surge.sh, etc.)

## Usage

This gem can be used in different ways, so the documentation is split up in different files:

* [I want to use the content of a DatoCMS site in my static website (Hugo, Jeckyll, etc.)](https://github.com/datocms/ruby-datocms-client/blob/master/docs/dato-cli.md);
* [I want to edit the contents of an existing DatoCMS site  programmatically](https://github.com/datocms/ruby-datocms-client/blob/master/docs/site-api-client.md);
* [I want to create new DatoCMS sites programmatically](https://github.com/datocms/ruby-datocms-client/blob/master/docs/account-api-client.md).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Updating the client when the API changes

The DatoCMS API provides an always up-to-date [JSON Hyperschema](http://json-schema.org/latest/json-schema-hypermedia.html): the code of this gem is generated automatically starting from the schema running `rake regenerate`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dato. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

