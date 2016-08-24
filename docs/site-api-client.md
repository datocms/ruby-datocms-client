# Edit the contents of an existing DatoCMS site

With this gem, you can easily create, edit and destroy any object within a DatoCMS site:

* Item types
* Fields
* Items
* MenuItems
* Users

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
require "dato"

# create a DatoCMS client
client = Dato::Site::Client.new("YOUR_SITE_API_READWRITE_TOKEN")

# create a new Article item type
article_type = client.item_types.create(
  name: "Article",
  singleton: false,
  sortable: false,
  api_key: "article"
)

# add a Title field to the Article item type
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

# add an Image field to the Article item type
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

# create a new Article
client.items.create(
  item_type: article_type[:id],
  title: "My first article!",
  image: client.upload_image("http://i.giphy.com/NXOF5rlaSXdAc.gif")
)

# fetch and edit an existing Article
article = client.items.find("1234")
client.items.update("1234", article.merge(title: "New title"))

# destroy an existing article
client.items.destroy("1234")
```

## List of client methods

```ruby
client.fields.create(item_type_id, resource_attributes)
client.fields.update(field_id, resource_attributes)
client.fields.all(item_type_id)
client.fields.find(field_id)
client.fields.destroy(field_id)

client.items.create(resource_attributes)
client.items.update(item_id, resource_attributes)
client.items.all(filters = {})
client.items.find(item_id)
client.items.destroy(item_id)

client.item_types.create(resource_attributes)
client.item_types.update(item_type_id, resource_attributes)
client.item_types.all
client.item_types.find(item_type_id)
client.item_types.destroy(item_type_id)

client.menu_items.create(resource_attributes)
client.menu_items.update(menu_item_id, resource_attributes)
client.menu_items.all
client.menu_items.find(menu_item_id)
client.menu_items.destroy(menu_item_id)

client.site.find
client.site.update(resource_attributes)

client.upload_requests.create(resource_attributes)

client.users.create(resource_attributes)
client.users.update(user_id, resource_attributes)
client.users.all
client.users.find(user_id)
client.users.reset_password(resource_attributes)
client.users.destroy(user_id)
```