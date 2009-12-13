# Set Whenever Gem
gem "whenever"

# Set the Backup Gem
gem "backup"

# Install the Gems
rake "gems:install",
  :sudo => true

# Run the Backup Generator
generate("backup")

# Initialize Whenever
run "sudo wheneverize ."

commit "Added Authlogic and Backup Gem Dependencies. Generated Backup and Initialized Whenever."