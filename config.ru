#require 'bundler'
#
#Bundler.setup
#Bundler.require(:runtime)

$: << "lib"
require './lib/app'
$stdout.sync = true

run EmovereApp
