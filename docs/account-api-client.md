# Create/edit sites within a DatoCMS account 

With this gem, you can easily create, edit and destroy DatoCMS sites, as well as editing your account settings.

# Installation

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
require "dato"

# fetch existing sites
sites = client.sites.all

# create a new site
site = client.sites.create(name: 'Foobar')

# update an existing site
client.sites.update(site[:id], site.merge(name: 'Blog'))

# destroy an existing site
client.sites.destroy(new_site[:id])
```

## List of client methods

```ruby
client.account.find
client.account.create(resource_attributes)
client.account.update(resource_attributes)
client.account.reset_password(resource_attributes)

client.sites.find(site_id)
client.sites.all
client.sites.create(resource_attributes)
client.sites.update(site_id, resource_attributes)
client.sites.destroy(site_id)
client.sites.duplicate(site_id, resource_attributes)
```