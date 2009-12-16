# Ensure that the Nifty Generators gem is installed
ensure_gem_installed("nifty-generators")

# Run Generators and Utilities
generate("nifty_layout --haml")

commit "Generated the base-template layout from Nifty Generators."