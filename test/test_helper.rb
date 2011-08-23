require File.dirname(__FILE__) + '/../lib/gtk_app'

class FooBar
  attr_accessor :attr1, :attr2
end

class Foo < FooBar; end
class Bar < FooBar; end