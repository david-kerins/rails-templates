# Removes all javascript files from javascript folder
run "rm -f public/javascripts/*"

# Installs the jRails plugin
plugin 'jrails', :git => 'git://github.com/aaronchi/jrails.git'

# Re-adds the application.js to the javascripts folder
run "touch public/javascripts/application.js"