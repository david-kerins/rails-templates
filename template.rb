# Remove unneeded files
run "rm README"
run "rm public/index.html"
run "rm -f public/javascripts/*"
run "rm -f public/images/*"

# Update Install Gems
run "sudo gem update --system"
run "sudo gem update"

# Set Gems
gem "rspec",
  :lib => false
gem "rspec-rails",
  :lib => false
gem "factory_girl" 
gem "formtastic"
gem "will_paginate"
gem "haml"
gem "whenever"
gem "backup"
gem "erubis"
gem "friendly_id"
gem "authlogic"

# Install Set Gems
rake "gems:install", :sudo => true
run "sudo gem install simple_generators"

# Install Plugins
plugin 'jrails',                      :git => 'git://github.com/aaronchi/jrails.git'
plugin 'exception_notifier',          :git => 'git://github.com/rails/exception_notification.git'
plugin 'rails_xss',                   :git => 'git://github.com/NZKoz/rails_xss.git'
plugin 'action_mailer_optional_tls',  :git => 'git://github.com/collectiveidea/action_mailer_optional_tls.git'
plugin 'validation_reflection',       :git => 'git://github.com/redinger/validation_reflection.git'

# Run Generators and Utilities
generate("nifty_layout --haml")
generate("rspec")
generate("backup")
generate("formtastic")
generate("friendly_id")
run "sudo wheneverize ."
run "sudo capify ."
run "sudo rm -f config/deploy.rb"

# Download Custom Capistrano Deployment Recipe
inside('config') do
  run 'curl -O http://gist.github.com/raw/157958/6900de4ad2208f0197b22bf7b07eabbca0bddd58/Capistrano-Deployment-Recipe.rb'
  run 'mv Capistrano-Deployment-Recipe.rb deploy.rb'
end

# Create the factories file
run "touch spec/factories.rb"

# Create TEXTILE README file
run "touch README.textile"

# Create and Migrate Database
rake "db:create"
rake "db:migrate"

# Add Gmail Support to Environment.rb
open('config/environment.rb', 'a') do |file|
  file << <<-SMTP
\n
ActionMailer::Base.smtp_settings = {
  :tls            => true,
  :address        => "smtp.gmail.com",
  :port           => "587",
  :domain         => "domain.com",
  :authentication => :plain,
  :user_name      => "user@domain.com",
  :password       => "password" 
}
  SMTP
end

# Set default Action Mailer url in development
open('config/environments/development.rb', 'a') do |file|
  file << "\n\nconfig.action_mailer.default_url_options = { :host => 'localhost:3000' }"
end

# Set default Action Mailer url in production
open('config/environments/production.rb', 'a') do |file|
  file << "\n\nconfig.action_mailer.default_url_options = { :host => 'domain.com' }"
end

# Create Git Repository and do an initial commit
file '.gitignore', <<-GIT
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
public/assets
public/system
public/javascripts/all.js
public/stylesheets/*.css
GIT

git :init
git :add => '.'
git :commit => "-a -m 'Initial Commit'"