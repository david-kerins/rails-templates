# Install the Action Mailer Optional TLS plugin
plugin 'action_mailer_optional_tls',
  :git => 'git://github.com/collectiveidea/action_mailer_optional_tls.git'

# Download the configuration
inside('config') do
  download_file('action_mailer_optional_tls/mail.rb')
end

# Add Gmail Support to Environment.rb
open('config/environment.rb', 'a') do |file|
  file << "\n\nrequire File.join(RAILS_ROOT, 'config', 'mail')"
end

# Set default Action Mailer url in development
open('config/environments/development.rb', 'a') do |file|
  file << "\n\nconfig.action_mailer.default_url_options = { :host => 'localhost:3000' }"
end

# Set default Action Mailer url in production
open('config/environments/production.rb', 'a') do |file|
  file << "\n\nconfig.action_mailer.default_url_options = { :host => 'domain.com' }"
end

commit "Installed action_mailer_optional_tls plugin. Setup default configuration in the environment files."