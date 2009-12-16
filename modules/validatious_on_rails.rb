# Set the validatious-on-rails Gem
gem "validatious-on-rails"

# Install the Gem
rake "gems:install",
  :sudo => true

# Generate the javascript files
generate "validatious"

inject_file('app/views/layouts/application.html.haml', /= yield\(:head\)/) do |match|
  "= javascript_include_tag 'XMLHttpRequest' ,'v2.standalone.full.min', 'v2.config', 'v2.rails'\n\s\s\s\s" +
  "= javascript_for_validatious\n\s\s\s\s#{match}"
end

commit "Installed the Validatious on Rails Gem and generated the javascript files."