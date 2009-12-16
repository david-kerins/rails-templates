# Ensure that Git is installed
ensure_gem_installed("git")

# Create a Git Ignore File
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

# Create Git Repository and do an initial commit
git :init
commit "Base Setup."