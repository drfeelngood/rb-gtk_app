module GtkApp
class Controller
  include GtkApp::Helpers
  include GtkApp::SignalSupport

  # @attribute [rw] model
  attr_accessor :model
  # @attr_accessor [rw] view
  attr_accessor :view

  def initialize(&block)
    instance_eval(&block) if block_given?

    establish_signal_connections
  end

  # @param [Boolean] with_validations
  def quit(with_validations=true)
    # TODO: if with_validations
    # end
    GtkApp.quit
  end

end
end