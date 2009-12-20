# Guide
# Configure the essential configurations below and do the following:
# 
#   Repository Creation:
#     cap deploy:repository:create
#     git add .
#     git commit -am "initial commit"
#     git push origin master
# 
#   Initial Deployment:
#     cap deploy:setup
#     cap deploy
#     cap deploy:gems:install
#     cap deploy:db:create
#     cap deploy:db:migrate
#     cap deploy:passenger:restart
#
#     (or run "cap deploy:initial" do run all of these)
#     
#   Then For Every Update Just Do:
#     git add .
#     git commit -am "some other commit"
#     git push origin master
#     cap deploy
#
#   For Apache2 Users
#     cap deploy:apache:create
#     cap deploy:apache:destroy
#     cap deploy:apache:restart
#     cap deploy:destroy_all:apache
#
#   For NginX Users
#     cap deploy:nginx:create
#     cap deploy:nginx:destroy
#     cap deploy:nginx:restart
#     cap deploy:destroy_all:nginx

# Configuration

# This configuration is *essential*

set   :ip,                  "123.45.6785.910"
set   :domain,              "domain.com"
set   :subdomain,           false # unless domain is a subdomain, e.g. subdomain.domain.com
set   :user,                "root"

# This configuration is *conventional*
set   :application,         ip
set   :deploy_to,           "/var/rails/#{domain}"
set   :repository_path,     "/var/git/#{domain}.git"
set   :repository,          "ssh://#{user}@#{application}#{repository_path}"

# The following configuration *optional*
set   :scm,                 "git"
set   :branch,              "master"
set   :use_sudo,            true
role  :web,                 application
role  :app,                 application
role  :db,                  application
default_run_options[:pty] = true 

# Symlinks
# that should be created after each deployment
#
# The index[0] is the shared_path
# The index[1] is the release_path
symlink_configuration = [
  %w(config/database.yml    config/database.yml),
  %w(db/production.sqlite3  db/production.sqlite3),
  %w(system                 public/system)
]

# Shared Folders
# That should be created inside the shared_path
directory_configuration = %w(db config system)






#
# Helper Methods
#

def create_tmp_file(contents)
  system 'mkdir tmp'
  file = File.new("tmp/#{domain}", "w")
  file << contents
  file.close
end

# 
# Do Not Alter The Recipe Below!
# 
namespace :deploy do
  
  # Tasks that run after the (cap deploy:setup)
  
  desc "Sets up the shared path"
  task :setup_shared_path do
    puts "\n\n=== Setting up the shared path! ===\n\n"
    directory_configuration.each do |directory|
      run "mkdir -p #{shared_path}/#{directory}"
    end
    system "cap deploy:db:update_yaml"
  end
  
  
  # Tasks that run after every deployment (cap deploy)
  
  desc "Initializes a bunch of tasks in order after the last deployment process."
  task :restart do
    puts "\n\n=== Running Custom Processes! ===\n\n"
    create_production_log
    setup_symlinks
    set_permissions
    system 'cap deploy:passenger:restart'
  end
 
  # Deployment Tasks
  
  desc "Executes the initial procedures for deploying a Ruby on Rails Application."
  task :initial do
    system "cap deploy:setup"
    system "cap deploy"
    system "cap deploy:gems:install"
    system "cap deploy:db:create"
    system "cap deploy:db:migrate"
    system "cap deploy:passenger:restart"
  end
  
  namespace :destroy_all do
    
    desc "Destroys Git Repository, Rails Environment and Apache2 Configuration."
    task :apache do
      system "cap deploy:repository:destroy"
      run "rm -rf #{deploy_to}"
      system "cap deploy:apache:destroy"
    end

    desc "Destroys Git Repository, Rails Environment and Nginx Configuration."
    task :nginx do
      system "cap deploy:repository:destroy"
      run "rm -rf #{deploy_to}"
      system "cap deploy:nginx:destroy"
    end
    
  end
  
  namespace :passenger do

    desc "Restarts Passenger"
    task :restart do
      puts "\n\n=== Restarting Passenger! ===\n\n"
      run "touch #{current_path}/tmp/restart.txt"
    end

  end
  
  desc "Sets permissions for Rails Application"
  task :set_permissions do
    puts "\n\n=== Setting Permissions! ===\n\n"
    run "chown -R www-data:www-data #{deploy_to}"
  end
  
  desc "Creates the production log if it does not exist"
  task :create_production_log do
    unless File.exist?(File.join(shared_path, 'log', 'production.log'))
      puts "\n\n=== Creating Production Log! ===\n\n"
      run "touch #{File.join(shared_path, 'log', 'production.log')}"
    end
  end
  
  desc "Creates symbolic links from shared folder"
  task :setup_symlinks do
    puts "\n\n=== Setting up Symbolic Links! ===\n\n"
    symlink_configuration.each do |config|
      run "ln -nfs #{File.join(shared_path, config[0])} #{File.join(release_path, config[1])}"
    end
  end
  
  # Manual Tasks
  
  namespace :db do
  
    desc "Syncs the database.yml file from the local machine to the remote machine"
    task :sync_yaml do
      puts "\n\n=== Syncing database yaml to the production server! ===\n\n"
      unless File.exist?("config/database.yml")
        puts "There is no config/database.yml.\n "
        exit
      end
      system "rsync -vr --exclude='.DS_Store' config/database.yml #{user}@#{application}:#{shared_path}/config/"
    end
    
    desc "Create Production Database"
    task :create do
      puts "\n\n=== Creating the Production Database! ===\n\n"
      run "cd #{current_path}; rake db:create RAILS_ENV=production"
      run "chown -R www-data:www-data #{deploy_to}"
    end
  
    desc "Migrate Production Database"
    task :migrate do
      puts "\n\n=== Migrating the Production Database! ===\n\n"
      run "cd #{current_path}; rake db:migrate RAILS_ENV=production"
      run "chown -R www-data:www-data #{deploy_to}"
    end
  
  end
  
  namespace :gems do
    
    desc "Installs any 'not-yet-installed' gems on the production server or a single gem when the gem= is specified."
    task :install do
      if ENV['gem']
        puts "\n\n=== Installing #{ENV['gem']}! ===\n\n"
        run "gem install #{ENV['gem']}"
      else
        puts "\n\n=== Installing required RubyGems! ===\n\n"
        run "cd #{current_path}; rake gems:install RAILS_ENV=production"
      end
    end

  end
  
  namespace :repository do

    desc "Creates the remote Git repository."
    task :create do
      puts "\n\n=== Creating remote Git repository! ===\n\n"
      run "mkdir -p #{repository_path}"
      run "cd #{repository_path} && git --bare init"
      system "git remote rm origin"
      system "git remote add origin #{repository[:repository]}"
      p "#{repository[:repository]} was added to your git repository as origin/master."
    end

    desc "Creates the remote Git repository."
    task :destroy do
      puts "\n\n=== destroying remote Git repository! ===\n\n"
      run "rm -rf #{repository_path}"
      system "git remote rm origin"
      p "#{repository[:repository]} (origin/master) was removed from your git repository."
    end

    desc "Resets the remote Git repository."
    task :reset do
      puts "\n\n=== Resetting remove Git repository! ===\n\n"
      system "cap deploy:repository:destroy"
      system "cap deploy:repository:create"
    end
    
    desc "Reinitializes Origin/Master."
    task :reinitialize do
      system "git remote rm origin"
      system "git remote add origin #{repository[:repository]}"
      p "#{repository[:repository]} (origin/master) was added to your git repository."
    end

  end
  
  namespace :environment do

    desc "Creates the production environment"
    task :create do
      system "cap deploy:setup"
    end

    desc "Destroys the production environment"
    task :destroy do
      run "rm -rf #{deploy_to}"
    end
  
    desc "Resets the production environment"
    task :reset do
      run "rm -rf #{deploy_to}"
      system "cap deploy:setup"
    end

  end
  
  namespace :crontab do
    
    desc "Update the crontab file for the Whenever Gem."
    task :update, :roles => :db do
      puts "\n\n=== Updating the Crontab! ===\n\n"
      run "cd #{release_path} && whenever --update-crontab #{domain}"
    end
    
  end

  namespace :apache do
    
    desc "Adds Apache2 configuration and enables it."
    task :create do
      puts "\n\n=== Adding Apache2 Virtual Host for #{domain}! ===\n\n"
      config = <<-CONFIG
      <VirtualHost *:80>
        ServerName #{domain}
        #{unless subdomain then "ServerAlias www.#{domain}" end}
        DocumentRoot #{File.join(deploy_to, 'current', 'public')}
      </VirtualHost>
      CONFIG
      
      system 'mkdir tmp'
      file = File.new("tmp/#{domain}", "w")
      file << config
      file.close 
      system "rsync -vr tmp/#{domain} #{user}@#{application}:/etc/apache2/sites-available/#{domain}"
      File.delete("tmp/#{domain}")
      run "sudo a2ensite #{domain}"
      run "sudo /etc/init.d/apache2 restart"
    end
    
    desc "Restarts Apache2."
    task :restart do
      run "sudo /etc/init.d/apache2 restart"
    end
    
    desc "Removes Apache2 configuration and disables it."
    task :destroy do
      puts "\n\n=== Removing Apache2 Virtual Host for #{domain}! ===\n\n"
      begin run("a2dissite #{domain}"); rescue; end
      begin run("sudo rm /etc/apache2/sites-available/#{domain}"); rescue; end
      run("sudo /etc/init.d/apache2 restart")
    end

  end
  
  namespace :nginx do
    
    desc "Adds NginX configuration and enables it."
    task :create do
      puts "\n\n=== Adding NginX Virtual Host for #{domain}! ===\n\n"
      config = <<-CONFIG
      server {
        listen 80;
        server_name #{unless subdomain then "www.#{domain} #{domain}" else domain end};
        root #{File.join(deploy_to, 'current', 'public')};
        passenger_enabled on;
      }
      CONFIG
      
      create_tmp_file(config)
      run "mkdir -p /opt/nginx/conf/sites-enabled"
      system "rsync -vr tmp/#{domain} #{user}@#{application}:/opt/nginx/conf/sites-enabled/#{domain}"
      File.delete("tmp/#{domain}")
      system 'cap deploy:nginx:restart'
    end
    
    desc "Restarts NginX."
    task :restart do
      Net::SSH.start(application, user) {|ssh| ssh.exec "/etc/init.d/nginx stop"}
      Net::SSH.start(application, user) {|ssh| ssh.exec "/etc/init.d/nginx start"}
    end
    
    desc "Removes NginX configuration and disables it."
    task :destroy do
      puts "\n\n=== Removing NginX Virtual Host for #{domain}! ===\n\n"
      begin
        run("rm /opt/nginx/conf/sites-enabled/#{domain}")
      ensure
        system 'cap deploy:nginx:restart'
      end
    end

  end
 
end
 
 
# Callbacks

after 'deploy:setup', 'deploy:setup_shared_path'