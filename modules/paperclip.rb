# Sets the Paperclip Gem
gem "paperclip"

# Install the Gems
rake "gems:install",
  :sudo => true

# Download Custom Capistrano Deployment Recipe
inside('lib/tasks') do
  download_file('paperclip_tasks.rake')
end

commit "Installed Paperclip, Downloaded Paperclip Rake Tasks."