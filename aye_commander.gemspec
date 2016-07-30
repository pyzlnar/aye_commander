$:.push File.expand_path("../lib", __FILE__)
require 'aye_commander/version'

Gem::Specification.new do |spec|
  spec.name       = 'aye_commander'
  spec.version    = AyeCommander::VERSION.dup
  spec.date       = '2016-06-30'
  spec.authors    = 'pyzlnar'
  spec.email      = 'pyzlnar@gmail.com'
  spec.homepage   = 'https://github.com/pyzlnar/aye_commander'
  spec.summary    = 'A simple command pattern gem'

  spec.license    = 'MIT'
  spec.files      = Dir["LICENSE", "README.adoc", "lib/**/*"]
  spec.test_files = Dir["spec/**/*"]
end
