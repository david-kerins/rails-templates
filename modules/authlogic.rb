# Set the Authlogic Gem
gem "authlogic"

# Install the Authlogic Gem
rake "gems:install",
  :sudo => true
  
# Generates the User Session file
generate "session user_session"

# Creates an initial scaffold for users
generate "nifty_scaffold user username:string role:string --haml"


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

inject_file("app/controllers/application_controller.rb", /class ApplicationController < ActionController::Base/) do |match|
<<-FILE
#{match}
  helper_method :current_user_session, :current_user
  include Authlogic::Custom::Helpers
FILE
end

# Inject into Users Controller
inject_file("app/controllers/users_controller.rb", /class UsersController < ApplicationController/) do |match|
<<-FILE
#{match}
  # before_filter :require_no_user, :only => [:new, :create]
  # before_filter :require_user, :only => [:show, :edit, :update]
FILE
end

inject_file("app/controllers/users_controller.rb", /class UsersController < ApplicationController/) do |match|
<<-FILE
#{match}
  # load_and_authorize_resource
FILE
end

inject_file("app/models/user.rb", /attr_accessible :username, :role/) do |match|
  ""
end

inject_file("app/models/user.rb", /class User < ActiveRecord::Base/) do |match|
<<-FILE
#{match}
  # Remove the :username attribute to ensure users cannot change their username at a later time
  attr_accessible :username, :email, :password, :password_confirmation
FILE
end


# Inject into User Model
inject_file("app/models/user.rb", /class User < ActiveRecord::Base/) do |match|
<<-FILE
#{match}
  
  acts_as_authentic do |c|
    c.validate_login_field(false)
  end
  
  # Allows users to sign in using both their username and email address
  def self.find_by_username_or_email(login)
    find_by_username(login) || find_by_email(login)
  end
  
  validates_length_of :username, :within => 3..30
  validates_format_of :username, :with => /^[\\w\\d_]+$/
FILE
end

inject_file("app/models/user_session.rb", /class UserSession < Authlogic::Session::Base/) do |match|
<<-FILE
#{match}
  # Allows users to sign in using both their username and email address
  find_by_login_method :find_by_username_or_email
FILE
end

inject_file("config/routes.rb", /map\.resources :users/) do |match|
<<-FILE
#{match}
  map.root :users
FILE
end


# Add Routes
route "map.resource :user_session,
    :collection => {:destroy => :get}"

route "map.sign_up 'sign-up',
    :controller => :users,
    :action     => :new"

route "map.logout 'logout',
    :controller => :user_sessions,
    :action     => :destroy"

route "map.login 'login',
    :controller => :user_sessions,
    :action     => :new"

commit "Added Authlogic Gem Dependency. Scaffolded a User model. Generated a User Session controller. Injected the AuthLogic class method inside the user model."