# Install Misc. Gems
run "sudo gem install nifty-generators" unless Gem.available? "nifty-generators"

# Run Generators and Utilities
generate("nifty_layout --haml")