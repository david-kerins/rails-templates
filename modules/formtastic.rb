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