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

    # sets up the signals like a boss
    def setup_signals
      signal_connect('button-press-event') do |me, event|
        if event.button == 3
          coords = window_to_buffer_coords(get_window_type(event.window), event.x, event.y)
          click_iter = get_iter_at_location(coords[0], coords[1])
          mark_click = buffer.create_mark('mark_click', click_iter, false)
        end
         false #let gtk process this event too. we don't want to eat any events
      end

      signal_connect('populate_popup') do |me, p_menu|
        menu = Gtk::Menu.new
        spell_menu_item = Gtk::MenuItem.new("Spelling Suggestions")
        mark_click = me.buffer.get_mark('mark_click')
        iters = get_word_iters(mark_click)
        add_suggestions_to_menu(menu, iters)
        spell_menu_item.set_submenu(menu)
        p_menu.insert(spell_menu_item, 0)
        p_menu.show_all
        false #let gtk process this event too
      end
    end

    # @param mark_click [Gtk::TextMark] mark at where the right-click occurs
    # @return [Array] start and end iter of the word of the passed mark
    def get_word_iters(mark_click)
      iter = buffer.get_iter_at_mark(mark_click)
      s_iter, e_iter = iter.clone, iter.clone
      s_iter.backward_word_start unless s_iter.starts_word?
      e_iter.forward_word_end unless e_iter.ends_word?
      [s_iter, e_iter]
    end

    # @param menu [Gtk::Menu] menu that is to be added upon
    # @param iters [Array of Gtk::TextIters] contains start and end iters of word
    # @return void - just adds the suggestions to the menu
    def add_suggestions_to_menu(menu, iters)
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
    end
  end
end
end
