ensure_gem_installed("daemons")

gem 'collectiveidea-delayed_job',
  :lib => 'delayed_job',
  :source => 'http://gems.github.com'

rake "gems:install",
  :sudo => true

open('Rakefile', 'a') do |file|
file << <<-FILE

begin
  require 'delayed/tasks'
rescue LoadError
  STDERR.puts "Run `rake gems:install` to install delayed_job"
end
  FILE
end

generate('delayed_job')

commit "Installed Delayed Job. Appended Tasks to the Rakefile and generated the migration file."