# Install Other Gems
run "sudo gem install hirb"

# Set default Action Mailer url in production
open('config/environments/development.rb', 'a') do |file|
  file << "\n\nrequire 'hirb'\nHirb.enable"
end