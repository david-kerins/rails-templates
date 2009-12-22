# Set the Authlogic Gem
gem "authlogic"

# Install the Authlogic Gem
rake "gems:install",
  :sudo => true
  
# Generates the User Session file
generate "session user_session"

# Creates an initial scaffold for users
generate "nifty_scaffold user username:string email:string --haml"


# Downloads Files
inside("db") do
  download_file("authlogic/authlogic_migration_columns")
end

inside("app/controllers") do
  download_file("authlogic/user_sessions_controller.rb")
end

run "mkdir -p app/views/user_sessions"
inside("app/views/user_sessions") do
  download_file("authlogic/new.html.haml")
end

run "mkdir -p lib/authlogic/custom"
inside("lib/authlogic/custom") do
  download_file("authlogic/helpers.rb")
end

inside("app/views/users") do
  run "rm _form.html.haml"
  download_file("authlogic/_form.html.haml")
end

inside("config/locales") do
  download_file("authlogic/authlogic.en.yml")
end

# Inject into Application Controller
inject_file("app/controllers/application_controller.rb", /# filter_parameter_logging :password/) do |match|
  "filter_parameter_logging :password, :password_confirmation"
end

inject_file("app/controllers/application_controller.rb", /helper :all/) do |match|
  "#{match}\n\thelper_method :current_user_session, :current_user" +
  "\n\tinclude Authlogic::Custom::Helpers\n\n"
end

# Inject into Users Controller
inject_file("app/controllers/users_controller.rb", /class UsersController < ApplicationController/) do |match|
  "#{match}\n\tbefore_filter :require_no_user, :only => [:new, :create]" +
  "\n\tbefore_filter :require_user, :only => [:show, :edit, :update]\n"
end

inject_file("app/models/user.rb", /attr_accessible :username, :email/) do |match|
  "attr_accessible :username, :email, :password, :password_confirmation"
end

# Inject into User Model
inject_file("app/models/user.rb", /class User < ActiveRecord::Base/) do |match|
  "#{match}\n\n\tacts_as_authentic do |c|\n\t\tc.validate_login_field(false)\n\tend\n\n" +
  "\tdef self.find_by_username_or_email(login)\n\t\tfind_by_username(login) || find_by_email(login)\n\tend\n\n" + 
  "\tvalidates_length_of :username, :within => 3..30\n\tvalidates_format_of :username, :with => /^[\\w\\d_]+$/"
end

inject_file("app/models/user_session.rb", /class UserSession < Authlogic::Session::Base/) do |match|
  "#{match}\n\n\tfind_by_login_method :find_by_username_or_email\n"
end


# Add Routes
route "map.resource :user_session, :collection => {:destroy => :get}"


commit "Added Authlogic Gem Dependency. Scaffolded a User model. Generated a User Session controller. Injected the AuthLogic class method inside the user model."