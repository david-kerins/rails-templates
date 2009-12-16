# Author:
#   Michael van Rooijen
# 
# Description:
#   This template sets up a Rails Stack that contains a bunch of stuff.
#   Here is a list in short:
#   
#   GEMS
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
#   FILES
#   - Removes the README
#   - Removes the index.html from the public folder
#   - Adds configuration for Action Mailer Optional TLS to config/environment.rb,
#     config/environments/development.rb and config/environments/produtcion.rb
#     so Gmail can be used with Action Mailer.
#
#   GIT
#   - Creates a .gitignore file containing essential file ignoration
#   - Initializes a new Git Repository
#   - Does an initial commit


# == Configuration ==============================

options = Hash.new

if yes? "Would you like to use all modules?"
  %w(jquery gmail capistrano authlogic backup_whenever friendly_id).each do |option|
    options[option.to_sym] = true
  end
else
  if yes? "Would you like Gmail support for Action Mailer? (This will enable you to use Gmail accounts to send emails)"
    options[:gmail] = true
  end
  
  if yes? "Will you be using jQuery as your javascript library/framework?"
    options[:jquery] = true
  end

  if yes? "Would you like to use Capistrano to deploy your Rails application?"
    options[:capistrano] = true
  end
  
  if yes? "Would you like to use Paperclip to enable file uploads and image manipulation?"
    options[:paperclip] = true
  end

  if yes? "Would you like to use Authlogic to handle authentication?"
    options[:authlogic] = true
  end

  if yes? "Would you like to setup Backup with Whenever for running periodic backups?"
    options[:backup_whenever] = true
  end

  if yes? "Would you like to use Friendly ID to be able to create \"pretty\" urls?"
    options[:friendly_id] = true
  end
end


# == Helper Methods ==============================

# Shortcut for loading modules
def load_module(m)
  load_template("http://github.com/meskyanichi/rails-templates/raw/master/modules/#{m}.rb")
end

# Shortcut for download files
def download_file(f)
  run("curl -O http://github.com/meskyanichi/rails-templates/raw/master/files/#{f}")
end

# Shortcut for doing commits
def commit(m)
  git(:add => '.')
  git(:commit => "-a -m 'Rails Template Commit: #{m}'")
end


# == Installation Start ==============================

# Remove unneeded files
run "rm README"
run "rm public/index.html"
run "rm -f public/images/*"

# Update Install Gems
run "sudo gem update --system"
run "sudo gem update"

# Set Default Gems
gem "formtastic"
gem "will_paginate"
gem "haml"
gem "erubis"

# Install Set Gems
rake "gems:install", :sudo => true

# Install Misc. Gems
run "sudo gem install nifty-generators" unless Gem.available? "nifty-generators"

# Install Plugins
plugin 'exception_notifier',          :git => 'git://github.com/rails/exception_notification.git'
plugin 'rails_xss',                   :git => 'git://github.com/NZKoz/rails_xss.git'
plugin 'validation_reflection',       :git => 'git://github.com/redinger/validation_reflection.git'

# Run Generators and Utilities
generate("nifty_layout --haml")
generate("formtastic")

# Add Exception Notifier Configuration to Environment
open('config/environment.rb', 'a') do |file|
  file << "\n\nExceptionNotifier.exception_recipients = %w(mail@some.random.domain.com mail2@some.random.domain.com)"
  file << "\n# Don't forget to add this inside the ApplicationController:\n# include ExceptionNotifiable"
end

# Load modules
load_module("git")
load_module("hirb")
load_module("rspec")
load_module("validatious-on-rails")

# Load optional modules
load_module("gmail")            if options[:gmail]
load_module("jquery")           if options[:jquery]
load_module("capistrano")       if options[:capistrano]
load_module("backup_whenever")  if options[:backup_whenever]
load_module("friendly_id")      if options[:friendly_id]
load_module("authlogic")        if options[:authlogic]
load_module("paperclip")        if options[:paperclip]

# Create and Migrate Database
rake "db:create"
rake "db:migrate"

p "Rails Application Installed!"