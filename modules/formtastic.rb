# Set the Formtastic Gem
gem "formtastic"

# Install the Gem
rake "gems:install",
  :sudo => true

# Install a plugin that works with Formtastic
plugin 'validation_reflection',
  :git => 'git://github.com/redinger/validation_reflection.git'

# Generate the Formtastic Stylesheets
generate("formtastic")