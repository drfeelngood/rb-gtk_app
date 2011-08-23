module GtkApp
class Controller
  include GtkApp::Helpers
  include GtkApp::SignalSupport

  attr_accessor :model, :view

  def initialize(&block)
    instance_eval(&block) if block_given?
    
    establish_signal_connections
  end

  def quit(with_validations=true)
    # TODO: if with_validations
    # end
    GtkApp.quit
  end

end
end