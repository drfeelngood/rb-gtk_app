require 'raspell'

module GtkApp
module TextEditSupport

  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods

    DEFAULT_LANG = "en_US"

    def initialize buffer=nil
      buffer ||= Gtk::TextBuffer.new
      super buffer
      setup_signals
    end

    def setup_signals
      window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
      window.add_events(Gdk::Event::BUTTON_PRESS_MASK)
      signal_connect('button-press-event') do |me, event|
        if event.button == 3
          menu = Gtk::Menu.new
          puts "I have been right clicked!"
          coords = window_to_buffer_coords(get_window_type(event.window), event.x, event.y)
          puts "#{coords[0]} #{coords[1]}"
          click_iter = get_iter_at_location(coords[0], coords[1])
          mark_click = buffer.create_mark('mark_click', click_iter, false)
        end
         false #let gtk process this event, too. we don't want to eat any events
      end

      signal_connect('populate_popup') do |me, p_menu|
        puts "called the populate popup signal"
        spell_menu_item = Gtk::MenuItem.new("Spelling Suggestions")
        menu = Gtk::Menu.new
        mark_click = me.buffer.get_mark('mark_click')
        iters = get_word_iters(mark_click)
        get_suggestions_menu(menu, iters)
        spell_menu_item.set_submenu(menu)
        p_menu.insert(spell_menu_item, 0)
        p_menu.show_all
        false
      end

      #app seg faults without the menu destroying properly. This still doesn't work.
      window.signal_connect('destroy-event') do |me|
        puts "hit destroy signal"
        menu.destroy
        Gtk.main_quit
      end
    end

    def get_word_iters(mark_click)
      s_iter = buffer.get_iter_at_mark(mark_click)
      s_iter.forward_word_end
      e_iter = s_iter.clone
      s_iter.backward_word_start
      [s_iter, e_iter]
    end

    def get_suggestions_menu(menu, iters)
      @spell_check = Aspell.new(DEFAULT_LANG)
      word = buffer.get_text(iters[0], iters[1])
      suggestions = @spell_check.suggest(word)[0...5]
      if suggestions.nil?
        label = Gtk::Label.new
        label.set_markup("<i>(no suggestions)</i>")
        menu.append(Gtk::MenuItem.new(label))
      else
        suggestions.each do |word|
          menu.append(sub=Gtk::MenuItem.new("#{word}"))
          sub.signal_connect('activate') do |widget|
            new_word = widget.label
            buffer.replace(new_word, iters[0], iters[1])
          end
        end
      end
      menu.show_all
    end

  end
end
end
