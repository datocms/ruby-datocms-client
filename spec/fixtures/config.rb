# frozen_string_literal: true

def helper_method_example
  puts "A helper method"
end

dato.available_locales.each do |_locale|
  create_data_file "site.yml", :yml, dato.site.to_hash

  directory "posts" do
    helper_method_example

    dato.articles.each do |post|
      create_post "#{post.slug}.md" do
        frontmatter :yaml, post.to_hash.merge!(image_url_with_focal_point: post.image.url(w: 150, h: 50, fit: :crop))
        content post.title
      end
    end
  end

  add_to_data_file "foobar.toml", :toml, sitename: dato.site.name
end
