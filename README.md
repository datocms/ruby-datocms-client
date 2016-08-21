# DatoCMS Ruby Client

[![Build Status](https://travis-ci.org/datocms/ruby-datocms-client.svg?branch=master)](https://travis-ci.org/datocms/ruby-datocms-client)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/dato`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dato'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dato

## Usage

```ruby
client = Dato::Site::Client.new("YOUR_SITE_API_TOKEN")

article_type = client.item_types.create(
  name: "Article",
  singleton: false,
  sortable: false,
  api_key: "article"
)

client.fields.create(
  article_type[:id],
  api_key: "title",
  field_type: "string",
  appeareance: { type: "title" },
  label: "Title",
  localized: false,
  position: 99,
  hint: "",
  validators: { required: {} },
)

client.fields.create(
  article_type[:id],
  api_key: "image",
  field_type: "image",
  appeareance: nil,
  label: "Image",
  localized: false,
  position: 99,
  hint: "",
  validators: { required: {} },
)

client.items.create(
  item_type: article_type[:id],
  title: "First post!",
  image: client.upload_image("http://i.giphy.com/NXOF5rlaSXdAc.gif")
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dato. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

