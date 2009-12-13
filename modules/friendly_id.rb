# Set the Friendly ID Gem
gem "friendly_id"

# Install the Gem
rake "gems:install",
  :sudo => true

# Generate the migration files for Friendly ID
generate("friendly_id")

commit "Added friendly_id Gem Depedency. Generated Friendly ID migration files."