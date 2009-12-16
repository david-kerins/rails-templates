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

# Ensures the specified gem is installed
def ensure_gem_installed(gem)
  run "sudo gem install #{gem}" unless Gem.available? gem
end


load_module "delayed_job"
exit

# == Installation Start ==============================

# Remove unneeded files
run "rm README"
run "rm public/index.html"
run "rm -f public/images/*"

# Update Install Gems
run "sudo gem update --system"
run "sudo gem update"

# Load default modules
load_module "git"
load_module "hirb"
load_module "rspec"
load_module "exception_notifier"
load_module "jrails"
load_module "haml"
load_module "formtastic"
load_module "validatious-on-rails"
load_module "rails_xss"
load_module "will_paginate"
load_module "nifty_generators"
load_module "capistrano"
load_module "backup_whenever"
load_module "action_mailer_optional_tls"
load_module "paperclip"
load_module "friendly_id"
load_module "delayed_job"
load_module "authlogic"

# Create and Migrate Database
rake "db:create"
rake "db:migrate"

# Downloads the TODO file
download_file("TODO_RAILS_TEMPLATE")

p "Rails Application Installed!"