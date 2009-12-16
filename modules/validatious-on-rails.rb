# Set the validatious-on-rails Gem
gem "validatious-on-rails"

# Install the Gem
rake "gems:install",
  :sudo => true

# Generate the javascript files
generate "validatious"