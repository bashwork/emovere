#require 'bundler'
#
#Bundler.setup
#Bundler.require(:runtime)

$: << "lib"
require 'emovere/web'
$stdout.sync = true

run EmovereApp
