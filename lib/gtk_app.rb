require 'gtk2'

module GtkApp
  lib = File.expand_path(File.dirname(__FILE__))

  autoload :Model,         "#{lib}/gtk_app/model"
  autoload :View,          "#{lib}/gtk_app/view"
  autoload :Controller,    "#{lib}/gtk_app/controller"

  autoload :Helpers,       "#{lib}/gtk_app/helpers"
  autoload :ViewHelpers,   "#{lib}/gtk_app/view_helpers"
  autoload :SignalSupport, "#{lib}/gtk_app/signal_support"
  autoload :TextBuffer,    "#{lib}/gtk_app/text_buffer"
  autoload :Observer,      "#{lib}/gtk_app/observer"
  autoload :Drawer,        "#{lib}/gtk_app/drawer"
  autoload :Version,       "#{lib}/gtk_app/version"

  # Start the main Gtk loop.
  def self.run
    Gtk::main
  end

  # Stop the main Gtk loop.
  def self.quit
    Gtk::main_quit
  end

  # Run a single iteration of the main loop while there are pending events 
  # without blocking.
  def self.refresh
    Gtk::main_iteration_do(false) while Gtk::events_pending?
  end

  # Establish a controller method to be invoked at regular intervals.
  # @param [Fixnum] time_in_milliseconds Time between calls to the receiver method.
  # @param [Object] controller The class in which the method exists.
  # @param [String] callback  Receiver method name.
  def self.add_timeout(time_in_milliseconds, controller, callback)
    GLib::Timeout.add(time_in_milliseconds){ controller.method(:"#{callback}") }
  end

end

require 'gtk_app/ext/text_view'
# require 'gtk_app/dialog'
