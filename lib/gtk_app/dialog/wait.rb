module GtkApp::Dialog
class Wait < Gtk::MessageDialog
  include GtkApp::Dialog::Support

  def initialize(parent)
    super(parent, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::OTHER,
      Gtk::Dialog::BUTTONS_NONE)
  end
end
end