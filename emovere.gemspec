$LOAD_PATH.unshift 'lib'
require 'emovere/version'

Gem::Specification.new do |s|
  s.name     = "emovere"
  s.version  = Emovere::Version
  s.data     = Time.now.strftime('%Y-%m-%d')
  s.summary  = "What does that emotion look like today"
  s.homepage = "http://github.com/bashwork/emovere"
  s.email    = "bashwork@gmail.com"
  s.authors  = [ "Galen Collins" ]
  s.files    = %w( README.rst LICENSE)
  s.files   += Dir.glob("lib/**/*")
  s.files   += Dir.glob("bin/**/*")
  s.files   += Dir.glob("man/**/*")
  s.files   += Dir.glob("test/**/*")
end

