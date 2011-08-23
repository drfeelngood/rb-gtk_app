module GtkApp::Dialog
class Error < Gtk::MessageDialog
  include GtkApp::Dialog::Support

  def initialize(parent)
    super(parent, Gtk::Dialog::MODAL | Gtk::Dialog::DESTROY_WITH_PARENT,
      Gtk::MessageDialog::ERROR, Gtk::MessageDialog::BUTTONS_CLOSE)
  end
  
end
end