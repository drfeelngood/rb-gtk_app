module GtkApp
class Drawer < Gtk::Window
  attr_reader :parent
  
  def initialize(parent, view)#, builder_file)
    @parent = parent
    # super(controller, builder_file)
    super(Gtk::Window::POPUP)
    p view.objects
    add_child(view, view.vboxMain)

    # TODO: normalize the following setup
    decorated = false
    # app_paintable = true
    resizable = true
    visible = true
    
    setup_signals
    show_all # TODO: replace with slide out/in methods
  end
  
  private
  
    def setup_signals
      @parent.signal_connect('configure-event') do |_window, event|
        align_to(event.x, event.y, event.width, event.height)
      end
    end
    
    def align_to(x, y, w, h)
      resize(size[0], h)
      move(x+w, y)
    end

end
end