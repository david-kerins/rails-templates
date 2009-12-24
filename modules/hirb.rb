# Ensure that HIRB is installed
ensure_gem_installed("hirb")

# Set default Action Mailer url in production
open('config/environments/development.rb', 'a') do |file|
file << <<-FILE
\n
require 'hirb'
Hirb.enable
FILE
end

commit "Added HIRB to the development environment. Initialized it from the config/environments/development.rb"