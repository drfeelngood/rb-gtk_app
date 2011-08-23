module GtkApp
module RegisterSupport
  
  module ClassMethods
    
    def register(widget_name, method_name, options={}, &block)
      # TODO:
    end
    
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
end
end