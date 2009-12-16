# Install the Rails XSS Plugin
plugin 'rails_xss',
  :git => 'git://github.com/NZKoz/rails_xss.git'
  
# Set the Erubis Gem Dependency (for Rails XSS)
gem "erubis"

# Install the Gem
rake "gems:install",
  :sudo => true
  
commit "Installed the Rails XSS plugin. Installed the Erubis Gem and added it as a dependency."