module GtkApp::Dialog
class Warn < Gtk::MessageDialog
  include GtkApp::Dialog::Support

  def initialize(parent)
    super(parent, Gtk::Dialog::MODAL | Gtk::Dialog::DESTROY_WITH_PARENT,
      Gtk::MessageDialog::WARNING, Gtk::MessageDialog::BUTTONS_OK_CANCEL)
  end

end
end