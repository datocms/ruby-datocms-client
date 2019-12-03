# 0.7.9

* Added new attributes to uploads

# 0.7.0

* Real-time events are now much more granular and the gem avoids downloading all the content every time a change occurs

# 0.6.18

* Fixed regression where you could no longer access items' item type

# 0.6.15

* Handle `429 Too Many Requests` responses from API

# 0.6.12

* Allow empty responses from server

# 0.6.10

* Introduced `.meta` on `Dato::Local::Item` to fetch all meta information about the records

# 0.6.5

* The `.seo_meta_tags` method now generates fallback titles based on the model field title

# v0.6.2

Moved `json_schema` as runtime dependency

# v0.6.1

The big change is that the methods the client makes available are  generated at runtime based on the [JSON Schema of our CMA](https://www.datocms.com/content-management-api/). This means any new API endpoint — or changes to existing ones — will instantly be reflected to the client, without the need to upgrade to the latest client version.

We also added a new `deserialize_response` option to every call, that you can use if you want to retrieve the exact payload the DatoCMS returns:

```ruby
require "dato"
client = Dato::Site::Client.new("YOUR-API-KEY")

# `deserialize_response` is true by default:
access_token = client.access_tokens.create(name: "New token", role: "34")

# {
#   "id" => "312",
#   "hardcoded_type" => nil,
#   "name" => "New token",
#   "token" => "XXXX",
#   "role" => "34"
# }

# if `deserialize_response` is false, this will be the result
access_token = client.access_tokens.create({ name: "New token", role: "34" }, deserialize_response: false)

# {
#   "data": {
#     "type": "access_token",
#     "id": "312",
#     "attributes": {
#       "name": "New token",
#       "token": "XXXX",
#       "hardcoded_type": nil
#     },
#     "relationships": {
#       "role": {
#         "data": {
#           "type": "role",
#           "id": "34"
#         }
#       }
#     }
#   }
# }
```

In our doc pages we also added some examples for the super-handy `all_pages` option which was already present since v0.3.29:

```ruby
# if you want to fetch all the pages with just one call:
client.items.all({ "filter[type]" => "44" }, all_pages: true)
```
