require 'rubygems'
require 'test/unit'

$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'gtk_app'
require 'gtk2'

module GtkAppTestHelper

  def tick
    while Gtk.events_pending?
      Gtk.main_iteration 
    end
  end

end

class FooBar
  attr_accessor :attr1, :attr2
end

class Foo < FooBar; end
class Bar < FooBar; end