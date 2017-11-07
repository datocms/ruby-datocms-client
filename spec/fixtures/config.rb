# frozen_string_literal: true
def helper_method_example
  puts 'A helper method'
end

dato.available_locales.each do |_locale|
  create_data_file 'site.yml', :yml, dato.site.to_hash

  directory 'posts' do
    helper_method_example
    dato.works.each do |post|
      create_post "#{post.slug}.md" do
        frontmatter :yaml, title: post.to_hash
        content post.excerpt
      end
    end
  end

  add_to_data_file 'foobar.toml', :toml, sitename: dato.site.name
end
