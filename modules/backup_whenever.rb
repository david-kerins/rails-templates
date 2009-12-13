# Set Whenever Gem
gem "whenever"
gem "backup"

rake "gems:install",
  :sudo => true

generate("backup")
run "sudo wheneverize ."