require File.dirname(__FILE__) + '/test_helper'
require 'test/unit'


class TestGtkApp < Test::Unit::TestCase
  
  def test_observer
    model = GtkApp::Model.new
    model.class_eval %{
      attr_accessor :foo
      attr_accessor :bar
    }
    GtkApp::Observer.observe(model)
    
    model.foo = 'hello world'
  end
  
end