require 'rake'
require 'open-uri'
require File.dirname(__FILE__) + '/lib/gtk_app/version'

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb', '-', 'README.md']
  end
rescue LoadError
end

desc "Publish gem and source."
task :publish => [:tag, :build] do
  sh "gem push gtk_app-#{GtkApp::Version}.gem"
  sh "git push origin v#{GtkApp::Version}"
  sh "git push origin master"  
end

desc "Build gtk_app RubyGem."
task :build do
  sh "gem build gtk_app.gemspec"
end

desc "Tag the current version."
task :tag do
  sh "git tag v#{GtkApp::Version}"
end

desc "Install current resque-batched-job RubyGem."
task :install => :build do
  sh "gem install --local gtk_app-#{GtkApp::Version}.gem"
end

desc "Remove all local RubyGems."
task :clean do
  sh "rm -fv gtk_app-*.gem"
end
