# Set the Formtastic Gem
gem "formtastic"

# Install a plugin that works with Formtastic
plugin 'validation_reflection',
  :git => 'git://github.com/redinger/validation_reflection.git'

# Install the Gem
rake "gems:install",
  :sudo => true

# Generate the Formtastic Stylesheets
generate("formtastic")

# Ensure that HAML is installed
ensure_gem_installed("haml")

# Convert CSS to SASS
inside('public/stylesheets') do
  run "mkdir sass"
  run "css2sass formtastic.css sass/formtastic.sass"
  run "css2sass formtastic_changes.css sass/formtastic_changes.sass"
  run "rm formtastic*"
end

inject_file('app/views/layouts/application.html.haml', /= stylesheet_link_tag 'application'/) do |match|
  "#{match}, 'formtastic', 'formtastic_changes'"
end

inject_file('config/initializers/formtastic.rb', /# Formtastic::SemanticFormBuilder.inline_errors = :sentence/) do
  "Formtastic::SemanticFormBuilder.inline_errors = :list"
end

inject_file('config/initializers/formtastic.rb', /# Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false/) do
  "Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true"
end

inside("config/locales") do
  run "rm -f en.yml"
  download_file("formtastic/formtastic.en.yml")
  download_file("formtastic/en.yml")
end

commit "Installed Formtastic and Validation Reflection. Generated the Formtastic CSS files and converted them to SASS files."