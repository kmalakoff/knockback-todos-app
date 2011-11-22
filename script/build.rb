# Run me with: 'ruby script/build.rb'
require 'rubygems'
PROJECT_ROOT = File.expand_path('../..', __FILE__)

####################################################
# Todos
####################################################
`cd #{PROJECT_ROOT}; coffee -b -o #{PROJECT_ROOT} -c #{PROJECT_ROOT}`