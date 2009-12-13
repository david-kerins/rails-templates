# Install Capistrano
run "sudo gem install capistrano"

# Initializ Capistrano
run "sudo capify ."

# Remove the generated deploy.rb
run "sudo rm -f config/deploy.rb"

# Download Custom Capistrano Deployment Recipe
inside('config') do
  download_file('deploy.rb')
end