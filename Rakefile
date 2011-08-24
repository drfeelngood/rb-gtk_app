require 'rake'
require 'rdoc/task'
require 'open-uri'
require File.dirname(__FILE__) + '/lib/gtk_app/version'

desc "Publish gem and source."
task :publish => :gem do
  sh "gem push gtk_app-#{GtkApp::Version}.gem"
  sh "git tag v#{GtkApp::Version}"
  sh "git push origin v#{GtkApp::Version}"
  sh "git push origin master"  
end

desc "Build gtk_app gem."
task :gem do
  sh "gem build gtk_app.gemspec"
end

namespace :gtk do
  
  desc "Download ruby-gtk-1.0.0 package"
  task :download do
    package = 'ruby-gtk2-1.0.0.tar.gz'
    output  = File.dirname(__FILE__) + "/#{package}"
    puts "Download => #{output}"
    File.open(output, "w") do |file|
      open("http://sourceforge.net/projects/ruby-gnome2/files/ruby-gnome2/ruby-gnome2-1.0.0/#{package}/download") do |io|
        file.write(io.read)
      end
    end
  end

end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end