require 'bundler'

Bundler.setup
Bundler.require(:runtime)

require './emovere'
$stdout.sync = true

run Emovere
