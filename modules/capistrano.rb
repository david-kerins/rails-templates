# Install Capistrano
run "sudo gem install capistrano" unless Gem.available? "capistrano"

# Initializ Capistrano
run "sudo capify ."

# Remove the generated deploy.rb
run "sudo rm -f config/deploy.rb"

# Download Custom Capistrano Deployment Recipe
inside('config') do
  download_file('deploy.rb')
end

commit "Installed Capistrano, Initialized Capistrano, Replaced default deploy.rb with custom deploy.rb."