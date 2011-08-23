module GtkApp::Dialog
class Ask < Gtk::MessageDialog
  include GtkApp::Dialog::Support

  def initialize(parent)
    super(parent, Gtk::Dialog::MODAL | Gtk::Dialog::DESTROY_WITH_PARENT,
      Gtk::MessageDialog::QUESTION, Gtk::MessageDialog::BUTTONS_YES_NO)
  end

end
end