# Ensure that Git is installed
ensure_gem_installed("git")

# Create a Git Ignore File
file '.gitignore', <<-FILE
.DS_Store
log/*.log
tmp/**/*
db/*.sqlite3
public/assets
public/system
public/javascripts/all.js
public/stylesheets/*.css
FILE

# Create Git Repository and do an initial commit
git :init
commit "Base Setup."