```ruby
StructuredTextRenderer.new(
  foo.content,
  adapter: Adapter.new(
    render_text: lambda do |text|
      text.gsub(/this/, "that")
    end,
    render_fragment: lambda do |children|
      children.join("")
    end,
    render_node: lambda do |tagname, attrs, children|
      # we could ActionView::Helpers::TagHelper
      content_tag(tagname, children, attrs)
    end,
  )
  custom_rules: {
    heading: lambda do |node, children, adapter|
      adapter.render_node("h#{node[:level] + 1}", {}, children)
    end
  },
  render_link_to_record: lambda do |record, children, adapter|
  end,
  render_inline_record: lambda do |record, adapter|
  end,
  render_block: lambda do |record, adapter|
  end
)
```