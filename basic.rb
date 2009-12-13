# Author:
#   Michael van Rooijen
# 
# Description:
#   This template sets up a Rails Stack that contains a bunch of stuff.
#   Here is a list in short:
#   
#   GEMS
#   - Removes the README and creates a README.textile
#   - Removes the index.html from the public folder
#   - Updates RubyGems and all the already installed gems
#   - RSpec: Set gem dependencies, installs gems, generate the Spec folder and files
#   - Factory Girl: Sets gem dependency, installs gem, creates the factories file in the spec/ folder
#   - Formtastic: Sets gem dependency, installs gem, generates the formtastic stylesheet
#   - HAML: Sets gem dependency, installs gem
#   - Will Paginate: Sets gem dependency, installs gem
#   - Authlogic: Sets gem dependency, installs gem
#   - Whenever: Sets gem dependency, installs gem, generates schedule.rb file in the config folder
#   - Backup: Sets gem dependency, installs gem, generates backup.rake in lib/tasks and backup.rb in the config folder, generates migration file
#   - Friendly Id: Sets gem dependency, installs gem, generates migration file
#   
#   PLUGINS
#   - jRails: Removes all javascript files from public/js and installs jRails which installs the jQuery library in public/js
#   - Exception Notifier: Installs Exception Notifier
#   - Rails XSS: Installs Rails XSS
#   - Action Mailer Optional TLS: Installs Action Mailer Optional TLS (To Enable Gmail for Action Mailer)
#   - Validation Reflection: Installs Validation Reflection for Formtastic
#
#   OTHER GENERATES
#   - Nifty Layout (hamalized)
#   - Capistrano Template (After initializing Capistrano with the capify command)
# 
#   DATABASE
#   - Creates
#   - Migrates
#
#   FILE WRITING
#   - Adds configuration for Action Mailer Optional TLS to config/environment.rb,
#     config/environments/development.rb and config/environments/produtcion.rb
#     so Gmail can be used with Action Mailer.
#
#   GIT
#   - Creates a .gitignore file containing essential file ignoration
#   - Initializes a new Git Repository
#   - Does an initial commit


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

# Install Other Gems
run "sudo gem install hirb"

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
  run 'curl -O http://github.com/meskyanichi/rails-templates/raw/master/capistrano/deploy.rb'
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
  file << "\n\nrequire 'hirb'\nHirb.enable"
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