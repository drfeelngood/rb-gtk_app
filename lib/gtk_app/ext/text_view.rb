module Gtk
  class TextView

    alias_method :gtk2_initialize, :initialize
    alias_method :gtk2_buffer=, :buffer=

    def initialize(buffer = nil)
      self.buffer = buffer
      self.gtk2_initialize(nil)
    end

    def buffer=(buffer)
      buffer.view = self if buffer.is_a?(GtkApp::TextBuffer)
      self.gtk2_buffer = buffer
    end
    
    # @api private
    def __button_press_event(event)
      if event.button == 3
        x, y = window_to_buffer_coords(Gtk::TextView::WINDOW_TEXT, *event.coords)
        iter, _ = get_iter_at_position(x, y)
        buffer.move_mark('click', iter)
      end
      false
    end

    # @api private
    def __populate_popup(menu)
      iter = buffer.get_iter_at_mark(buffer.text_marks[:click])
      s_iter, e_iter = iter.clone, iter.clone
      
      s_iter.backward_word_start unless s_iter.starts_word?
      e_iter.forward_word_end if e_iter.inside_word?
    
      word = buffer.get_text(s_iter, e_iter)

      menu_item = Gtk::MenuItem.new("Spelling Suggestions")
      submenu   = Gtk::Menu.new
      buffer.spell_check.send(:suggestions, word).each_with_index do |wurd, ndx|
        _menu_item = Gtk::MenuItem.new(wurd)
        _menu_item.signal_connect('activate') do |mi|
          buffer.begin_user_action
          buffer.delete(s_iter, e_iter)
          buffer.insert(s_iter, mi.label)
          buffer.end_user_action
        end
        submenu.append(_menu_item)
      end 
      menu_item.submenu = submenu
      menu.prepend(menu_item)
      menu.show_all
    end

  end
end
