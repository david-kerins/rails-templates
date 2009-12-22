# Set the CanCan Gem
gem "cancan"

# Install the CanCan Gem
rake "gems:install",
  :sudo => true

inside('app/models') do
  download_file('cancan/ability.rb')
end

run "mkdir -p lib/cancan"
inside('lib/cancan') do
  %w(guest user moderator admin).each do |file|
    download_file("cancan/#{file}.rb")
  end
end

commit "Added CanCan Gem Dependency. Added the Ability file."