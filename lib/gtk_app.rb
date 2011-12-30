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
  autoload :Version,       "#{lib}/gtk_app/version"

  def self.run
    Gtk::main
  end

  def self.quit
    Gtk::main_quit
  end

  def self.refresh
    Gtk::main_iteration_do(false) while Gtk::events_pending?
  end

  # @param [Fixnum] time_in_milliseconds
  # @param [Object] controller
  # @param [String] callback
  def self.add_timeout(time_in_milliseconds, controller, callback)
    GLib::Timeout.add(time_in_milliseconds){ controller.method(:"#{callback}") }
  end

end

# require 'gtk_app/dialog'
