# Set the CanCan Gem
gem "cancan"

# Install the CanCan Gem
rake "gems:install",
  :sudo => true

inside('app/models') do
  download_file('cancan/ability.rb')
end

commit "Added CanCan Gem Dependency. Added the Ability file."