# Set Whenever Gem
gem "whenever"

# Install the Gem
rake "gems:install",
  :sudo => true

# Initialize Whenever
run "sudo wheneverize ."

commit "Whenever Gem Dependency.Initialized Whenever."