gem 'collectiveidea-delayed_job',
  :lib => 'delayed_job',
  :source => 'http://gems.github.com'

rake "gems:install",
  :sudo => true

open('Rakefile', 'a') do |file|
  file << <<-CONFIG
\n
begin
  require 'delayed/tasks'
rescue LoadError
  STDERR.puts "Run `rake gems:install` to install delayed_job"
end
  CONFIG
end

generate('delayed_job')