# Install the Exception Notifier Plugin
plugin 'exception_notifier',
  :git => 'git://github.com/rails/exception_notification.git'

# Add Exception Notifier Configuration to Environment
open('config/environment.rb', 'a') do |file|
  file << "\n\nExceptionNotifier.exception_recipients = %w(mail@example.com mail2@example.com)"
end

# Injects the include ExceptionNotifiable module into the ApplicationController
inject_file('app/controllers/application_controller.rb', /class ApplicationController < ActionController::Base/) do |match|
<<-FILE
#{match}
  include ExceptionNotifiable
FILE
end

commit "Installed Exception Notifier Plugin and added the exception_recipients to the environment.rb file."