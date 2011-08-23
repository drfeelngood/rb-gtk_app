module GtkApp::Dialog
class Info < Gtk::MessageDialog
  include GtkApp::Dialog::Support

  def initialize(parent)
    super(parent, Gtk::Dialog::MODAL | Gtk::Dialog::DESTROY_WITH_PARENT,
      Gtk::MessageDialog::INFO, Gtk::MessageDialog::BUTTONS_OK)
  end
  
end
end