# Author: Michael van Rooijen
# Description:
#  This recipe is designed to work for people using Phusion Passenger,
#  Git as your repository.
#
# Steps:
# The First Deployment / Setup
#  - cap deploy:setup
#  - cap deploy
#  - cap deploy:migrate_production_database
# 
# Then all the other times:
#  - cap deploy
# 
# 
# The "Restart" task inside the "Deploy" namespace is what gets initialized at the end of the
# Capistrano process. In order, other tasks will be initialized to make the deployment work.
# You can create more tasks and add them to the list of tasks in the "Restart" task.
# Just be sure that you place them in a good (working) order so that it works.
 
# SETTINGS
# Application Domain (example.domain.com)
# Be sure to fill in the correct domain name for your web application!
set :application, "domain.com"
 
# Set server where the application is going to be uploaded to.
# Automatically filled in with the application variable.
role :web,  application
role :app,  application
role :db,   application
 
# Crontab
# Change "application" to whatever you want if you wish to use a different identifier
# to reduce the chance it might conflict with another application.
set :crontab_id,  application
 
# SSH Address
# Change "application" to whatever you want if you wish to use a dfferent address to connect to.
# This can either be an IP or a URL that points at the same IP.
set :ssh_address,  application
 
# Set the user
# :user       => Set the user that will attempt to access the remote repository
# :deploy_to  => Set the deployment location (destination) on the remote server
# :use_sudo   => Set to false
set :user,      "root" 
set :deploy_to, "/var/rails/domain.com"
set :use_sudo,  false
 
# Git Repository Location
# :scm        => Specify the source code management tool you want to use (default is git)
# :repository => Assign the repository location where the application resides
# :branch     => Select the branch that capistrano should fetch from (default is master)
set :scm,         "git"
set :repository,  "ssh://root@domain.com/var/git/domain.git"
set :branch,      "master"
 
# Required: default_run_options[:pty] - This will allow the user to connect to protected repository after
# logging in when the system prompts for the server's root password
# default_run_options => (default is true)
default_run_options[:pty] = true 
 
 
 
namespace :deploy do
  
  desc "Initializes a bunch of tasks in order after the last deployment process."
  task :restart do
    puts "\n\n\n\n=== Running Custom Processes! ===\n\n\n\n"
    create_production_log
    create_symlinks
    install_gems
    setup_crontab
    set_permissions
    restart_passenger
  end
 
 
  # Deployment Tasks
  
  desc "Restarts Passenger"
  task :restart_passenger do
    puts "\n\n\n\n=== Restarting Passenger! ===\n\n\n\n"
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Sets permissions for Rails Application"
  task :set_permissions do
    puts "\n\n\n\n=== Setting Permissions! ===\n\n\n\n"
    run "chown -R www-data:www-data #{deploy_to}"
  end
  
  desc "Creates the production log if it does not exist"
  task :create_production_log do
    unless File.exist?(File.join(shared_path, 'log', 'production.log'))
      puts "\n\n\n\n=== Creating Production Log! ===\n\n\n\n"
      run "touch #{File.join(shared_path, 'log', 'production.log')}"
    end
  end
  
  desc "Creates symbolic links from shared folder"
  task :create_symlinks do
    puts "\n\n\n\n=== Setting up Symbolic Links! ===\n\n\n\n"
    run "ln -nfs #{File.join(shared_path, 'config', 'database.yml')}        #{File.join(release_path, 'config', 'database.yml')}"
    run "ln -nfs #{File.join(shared_path, 'db',     'production.sqlite3')}  #{File.join(release_path, 'db',     'production.sqlite3')}"
    run "ln -nfs #{File.join(shared_path, 'assets')}                        #{File.join(release_path, 'public', 'assets')}"
    run "ln -nfs #{File.join(shared_path, 'system')}                        #{File.join(release_path, 'public', 'system')}"
  end
  
  desc "Update the crontab file for the Whenever Gem."
  task :setup_crontab, :roles => :db do
    puts "\n\n\n\n=== Updating the Crontab! ===\n\n\n\n"
    run "cd #{release_path} && whenever --update-crontab #{crontab_id}"
  end
 
  desc "Installs any 'not-yet-installed' gems on the production server."
  task :install_gems do
    puts "\n\n\n\n=== Installing required RubyGems! ===\n\n\n\n"
    run "cd #{current_path}; rake gems:install RAILS_ENV=production"
  end
  
  
  # Manual Tasks
  
  desc "Syncs the database.yml file from the local machine to the remote machine"
  task :sync_database_yaml do
    puts "\n\n\n\n=== Syncing database yaml to the production server! ===\n\n\n\n"
    system "rsync -vr --exclude='.DS_Store' config/database.yml #{user}@#{ssh_address}:#{shared_path}/config/"
  end
  
  desc "Migrate Production Database"
  task :migrate_production_database do
    puts "\n\n\n\n=== Setting up Production Database! ===\n\n\n\n"
    run "cd #{current_path}; rake db:migrate RAILS_ENV=production"
    run "chown -R www-data:www-data #{deploy_to}"
  end
 
  desc "Resets the production environment"
  task :reset_rails_environment do
    run "rm -rf #{deploy_to}"
    system "cap deploy:setup"
  end
  
  
  # Initial Setup Tasks
  
  desc "Sets up the shared path"
  task :setup_shared_path do
    puts "\n\n\n\n=== Setting up the shared path! ===\n\n\n\n"
    run "mkdir -p #{shared_path}/db #{shared_path}/assets #{shared_path}/config"
    sync_database_yaml
  end
 
end
 
 
# Callbacks
 
after 'deploy:setup', 'deploy:setup_shared_path'