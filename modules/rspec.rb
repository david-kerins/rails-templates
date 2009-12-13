gem "rspec", :lib => false
gem "rspec-rails", :lib => false
gem "factory_girl"

rake "gems:install",
  :sudo => true

generate("rspec")

# Create the factories file
run "touch spec/factories.rb"