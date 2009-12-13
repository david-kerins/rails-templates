run "sudo gem install git"

# Create Git Repository and do an initial commit
file '.gitignore', <<-GIT
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
public/assets
public/system
public/javascripts/all.js
public/stylesheets/*.css
GIT

git :init
git :add => '.'
git :commit => "-a -m 'Initial commit'"