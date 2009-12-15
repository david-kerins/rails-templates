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
#


# Configuration

# This configuration is essential
set   :application,         "mydomain.com"
set   :user,                "root" 
set   :deploy_to,           "/var/rails/#{application}"
set   :repository_path,     "/var/git/#{application}.git"
set   :repository,          "ssh://#{user}@#{application}#{repository_path}"

# The following configuration usually doesn't need to be altered (much)
set   :scm,                 "git"
set   :branch,              "master"
set   :use_sudo,            false
role  :web,                 application
role  :app,                 application
role  :db,                  application
default_run_options[:pty] = true 

# Symlinks that should be created (append more or remove)
# The index[0] is the shared_path
# The index[1] is the release_path
symlink_configuration = [
  ['config/database.yml',     'config/database.yml'   ],
  ['db/production.sqlite3',   'db/production.sqlite3' ],
  ['assets',                  'public/assets'         ],
  ['system',                  'public/system'         ]
]

namespace :deploy do
  
  # Tasks that run after the (cap deploy:setup)
  
  desc "Sets up the shared path"
  task :setup_shared_path do
    puts "\n\n=== Setting up the shared path! ===\n\n"
    run "mkdir -p #{shared_path}/db #{shared_path}/assets #{shared_path}/system #{shared_path}/config"
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
    task :update_yaml do
      puts "\n\n=== Syncing database yaml to the production server! ===\n\n"
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
      run "cd #{release_path} && whenever --update-crontab #{application}"
    end
    
  end

  namespace :apache do
    
    desc "Adds Apache2 configuraion and enables them."
    task :create do
      puts "\n\n=== Adding Apache2 Virtual Host for #{application}! ===\n\n"
      config = <<-CONFIG
      <VirtualHost *:80>
        ServerName #{application}
        ServerAlias www.#{application}
        DocumentRoot #{File.join(deploy_to, 'current', 'public')}
      </VirtualHost>
      CONFIG
      
      file = File.new("tmp/#{application}", "w")
      file << config
      file.close 
      system "rsync -vr tmp/#{application} #{user}@#{application}:/etc/apache2/sites-available/#{application}"
      File.delete("tmp/#{application}")
      run "sudo a2ensite #{application}"
      run "sudo /etc/init.d/apache2 restart"
    end
    
    desc "Adds Apache2 configuraion and enables them."
    task :destroy do
      puts "\n\n=== Removing Apache2 Virtual Host for #{application}! ===\n\n"
      begin run("a2dissite #{application}"); rescue; end
      begin run("sudo rm -f /etc/apache2/sites-available/#{application}"); rescue; end
      begin run("sudo /etc/init.d/apache2 restart"); rescue; end
    end

  end
 
end
 
 
# Callbacks

after 'deploy:setup', 'deploy:setup_shared_path'