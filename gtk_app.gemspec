require 'rubygems'
require File.dirname(__FILE__) + '/lib/gtk_app/version'

Gem::Specification.new do |s|
  s.name        = "gtk_app"
  s.version     = "#{GtkApp::Version}"
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.homepage    = "https://github.com/drfeelngood/rb-gtk_app"
  s.authors     = ["Daniel Johnston"]
  s.email       = "dan@dj-agiledev.com"
  s.license     = 'MIT'
  s.required_ruby_version = '>= 1.9.2'
  s.summary     = "A ruby-gtk framework"
  s.has_rdoc    = true

  s.add_dependency('pkg-config')
  s.add_dependency('activemodel', '>= 3.0.7')
  # s.add_dependency('dmarkow-raspell')
  s.add_dependency('raspell')
  
  s.files = Dir.glob(File.dirname(__FILE__) + '/lib/**/*')
end