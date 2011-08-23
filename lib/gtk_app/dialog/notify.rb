module GtkApp
module Dialog
class Notify < Gtk::Window
  DEFAULT_OPTIONS = { 
    :decorated  => false, 
    :resizable  => false, 
    :keep_above => true,
    :opacity    => 0.8,
    :bg_color   => 'lightgray',
    :padding    => 6,
    :pixbuf     => File.dirname(__FILE__) + '/notify.xpm',
    :pixmap     => File.dirname(__FILE__) + '/notify.xpm',
    :label_fg   => "#ffffff"
  }.freeze
  
  attr_reader :display

  def initialize(title, text, options={})
    @screen_info = {}
    conf = DEFAULT_OPTIONS.merge(options)

    screen = Gdk::Screen.default
    # @screen_info[:monitor]  = screen.monitor
    @screen_info[:geometry] = screen.monitor_geometry(screen.number)
    # @screen_info[:x] =
    # @screen_info[:y] = 

    super(Gtk::Window::POPUP)

    self.title = title
    self.decorated  = conf[:decorated]
    self.resizable  = conf[:resizable]
    self.keep_above = conf[:keep_above]
    self.stick
    
    ebox = Gtk::EventBox.new
    ebox.visible_window = false
    self.add(ebox)
    vbox = Gtk::VBox.new(false, conf[:padding])
    vbox.border_width = 12
    ebox.add(vbox)
    hbox = Gtk::HBox.new(false, conf[:padding])
    vbox.pack_start(hbox, false, true, 0)

    image = Gtk::Image.new(Gdk::Pixbuf.new(conf[:pixbuf]))
    hbox.pack_start(image, false, false, 0)
    
    label = Gtk::Label.new(title)
    label.modify_fg(Gtk::STATE_NORMAL, Gdk::Color.parse(conf[:label_fg]))
    hbox.pack_start(label, false, false, 0)

    label = Gtk::Label.new(text)
    label.justify = Gtk::JUSTIFY_LEFT
    label.modify_fg(Gtk::STATE_NORMAL, Gdk::Color.parse(conf[:label_fg]))
    label.wrap = true
    # label.wrap_mode = true
    vbox.pack_start(label, true, false, 0)
    
    ebox.signal_connect('button-press-event') do |widget|
      puts "button-press-event"
    end
    
    ebox.signal_connect('enter-notify-event') do |widget|
      puts "enter-notify-enter"
    end
    
    ebox.signal_connect('leave-notify-event') do |widget|
      puts "leave-notify-event"
    end

    self.app_paintable = true
    self.opacity = 0
    self.show_all
    # 
    # pixmap = Gdk::Pixmap.create_from_xpm(self, nil, conf[:pixmap])
    # puts pixmap.size
    # # Gdk::Drawable.new()
    # self.shape_combine_mask(pixmap, 0, 0)
  end
  
  def display
    
  end

end
end
end