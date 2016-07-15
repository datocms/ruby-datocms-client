require 'spec_helper'

describe Dato do
  it 'has a version number' do
    expect(Dato::VERSION).not_to be nil
  end

  it 'creates a module for each API resource' do
    client = Dato::Client.new(ENV.fetch("SITE_TOKEN"))
    creation = client.item_types.all.last
    items = client.items.all({ "filter[type]" => 74 })
    menu_item = client.menu_items.all.last
    fields = client.fields.all(creation[:id])
    site = client.site.find

    client.site.update(site)

    new_menu_item = client.menu_items.create(
      label: "Foobar",
      position: 99,
      parent: menu_item[:id],
      item_type: creation[:id]
    )

    client.menu_items.update(new_menu_item[:id], new_menu_item)
    client.menu_items.destroy(new_menu_item[:id])

    new_item_type = client.item_types.create({
      name: "Waza",
      singleton: true,
      sortable: false,
      api_key: "waza"
    })
    client.item_types.update(new_item_type[:id], new_item_type)

    new_field = client.fields.create(new_item_type[:id], {
      api_key: "stocazzo",
      field_type: "integer",
      appeareance: {},
      hint: "Foobar",
      label: "Stocazzo",
      localized: false,
      position: 99,
      validators: {},
    })

    client.fields.update(new_field[:id], new_field)

    new_item = client.items.create({
      item_type: new_item_type[:id],
      stocazzo: 12
    })

    new_item = client.items.update(
      new_item[:id],
      {
        id: new_item[:id],
        stocazzo: 44
      }
    )

    client.fields.destroy(new_field[:id])
    client.item_types.destroy(new_item_type[:id])

    expect(new_item[:stocazzo]).to eq 44
  end
end
