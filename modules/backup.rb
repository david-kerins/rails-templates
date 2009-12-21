# Set the Backup Gem
gem "backup"

# Install the Gem
rake "gems:install",
  :sudo => true

# Run the Backup Generator
generate("backup")

commit "Added Backup Gem Dependency. Generated Backup files."