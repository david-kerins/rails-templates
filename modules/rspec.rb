# Set the RSpec Gem
gem "rspec", :lib => false

# Set the RSpec for Rails Gem
gem "rspec-rails", :lib => false

# Set the Factory Girl Gem
gem "factory_girl"

# Install the Gems
rake "gems:install",
  :sudo => true

# Generate the inital RSpec folders and files
generate("rspec")

# Create the Factory Girl's factories file
inside("spec") do
  download_file("factories.rb")
end

# Require factories file inside the spec_helper.rb
open('spec/spec_helper.rb', 'a') do |file|
  file << "\n\nrequire File.dirname(__FILE__) + \"/factories\""
end

commit "Added Rspec, Rspec Rails and Factory Girl Gem Dependencies. Generated initial RSpec folders and files. Downloaded a simple Factories template. Added a require statement to the spec_helper.rb"