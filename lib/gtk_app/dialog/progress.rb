module GtkApp::Dialog
class Progress < Gtk::Dialog
  
  def initialize(parent)
    
    super("test", parent, 
      Gtk::Dialog::DESTROY_WITH_PARENT,
      [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_NONE])
    pbar = Gtk::ProgressBar.new
    hbox = Gtk::HBox.new(false, 6)
    hbox.pack_start(pbar, true, false, 6)
    self.vbox.add(hbox)
    self.show_all
  end
  
  # def +(amt)
  # end
  
end
end