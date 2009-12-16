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
  run "css2sass formtastic.css sass/formtastic.sass"
  run "css2sass formtastic_changes.css sass/formtastic_changes.sass"
end