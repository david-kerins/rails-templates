# Install the Action Mailer Optional TLS plugin
plugin 'action_mailer_optional_tls',  :git => 'git://github.com/collectiveidea/action_mailer_optional_tls.git'

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