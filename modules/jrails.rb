# Removes all javascript files from javascript folder
%w(prototype controls dragdrop effects).each do |file|
  run "rm -f public/javascripts/#{file}.js"
end

# Installs the jRails plugin
plugin 'jrails',
  :git => 'git://github.com/aaronchi/jrails.git'

commit "Removed all javascript files. Installed the jRails plugin. Added jQuery files and application.js to the javascripts folder."