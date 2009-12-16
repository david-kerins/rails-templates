# Removes all javascript files from javascript folder
%w(prototype controls dragdrop effects).each do |file|
  run "rm -f public/javascripts/#{file}.js"
end

# Installs the jRails plugin
plugin 'jrails',
  :git => 'git://github.com/aaronchi/jrails.git'

# Injects the javascript_include_tag for jRails/jQuery into the application.html.haml file
inject_file('app/views/layouts/application.html.haml', /= yield\(:head\)/) do |match|
  "= javascript_include_tag 'jquery', 'jquery-ui', 'jrails'\n\s\s\s\s#{match}"
end


commit "Removed all javascript files. Installed the jRails plugin. Added jQuery files and application.js to the javascripts folder."