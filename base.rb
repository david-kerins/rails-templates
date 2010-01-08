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
#   - CanCan: Sets gem dependency, installs gem, adds the ability.rb to models folder
#   - Delayed Job: Sets gem dependency, installs gem, updates Rakefile
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
#   - Does a commit for every installed module


# == Helper Methods ============================== 

# Methods for storing modules that are requested
def modules
  @modules ||= Array.new
  @modules
end

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
def ensure_gem_installed(g)
  unless Gem.available? g
    run "sudo gem install #{g}"
  end
end


# Inserts text into a file
def inject_file(path, regexp, *args, &block)
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end


# == Modules To Be Loaded ============================

if yes? "Would you like to use Authlogic and CanCan for Authentication and Authorization?"
  modules << :authlogic
  modules << :cancan
end


# == Installation Start ==============================

# Remove unneeded files
run "rm README"
run "rm public/index.html"
run "rm -f public/images/*"
run "cp config/database.yml config/database.yml.example"

# Update installed gems
run "sudo gem update --system"
run "sudo gem update"

# Load required modules
load_module "git"
load_module "rspec"
load_module "haml"
load_module "nifty_generators"
load_module "formtastic"

# Load additional modules
load_module "jrails"
load_module "validatious_on_rails"
load_module "rails_xss"
load_module "will_paginate"
load_module "capistrano"
load_module "backup"
load_module "whenever"
load_module "action_mailer_optional_tls"
load_module "paperclip"
load_module "friendly_id"
load_module "delayed_job"
load_module "hirb"
load_module "exception_notifier"

# Load optional modules
modules.each do |m|
  load_module(m.to_s)
end

p "Rails Application Installed!"
p "Create and Migrate the database after applying any optional changes."