$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'aye_commander/version'

Gem::Specification.new do |spec|
  spec.name        = 'aye_commander'
  spec.version     = AyeCommander::VERSION.dup
  spec.authors     = 'pyzlnar'
  spec.email       = 'pyzlnar@gmail.com'
  spec.homepage    = 'https://github.com/pyzlnar/aye_commander'
  spec.summary     = 'A simple command pattern gem'
  spec.description = 'A gem that helps to write commands in ruby.'

  spec.license    = 'MIT'
  spec.files      = Dir['LICENSE', 'README.adoc', 'lib/**/*']
  spec.test_files = Dir['spec/**/*']
  spec.required_ruby_version = '>= 2.0.0'
end
