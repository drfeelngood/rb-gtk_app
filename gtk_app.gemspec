require 'rubygems'

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'lib/gtk_app'

Gem::Specification.new do |s|
  s.name        = "gtk_app"
  s.version     = "#{GtkApp::Version}"
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.homepage    = "https://github.com/drfeelngood/rb-gtk_app"
  s.authors     = ["Daniel Johnston"]
  s.email       = "dan@dj-agiledev.com"
  
  s.summary     = "A ruby-gtk framework"

  # s.add_dependency('pkg-config')
  # s.add_dependency('active_model', '>= 3.0.7')
  
  s.files = Dir.glob(File.dirname(__FILE__) + '/lib/**/*')

end