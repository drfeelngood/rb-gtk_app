require 'raspell'

module GtkApp
module TextEditSupport

  def self.included(base)
    base.send(:include, InstanceMethods)
    #base.setup_signals
  end

  module InstanceMethods

    DEFAULT_LANG = "en_US"

    def initialize buffer=nil
      buffer ||= Gtk::TextBuffer.new
      super buffer
      setup_signals
    end

    def setup_signals

      signal_connect('button-press-event') do |me, event|
        if event.button == 3
          menu = Gtk::Menu.new
          puts "I have been right clicked!"
          coords = window_to_buffer_coords(get_window_type(event.window), event.x, event.y)
          puts "#{coords[0]} #{coords[1]}"
          click_iter = get_iter_at_location(coords[0], coords[1])
          mark_click = buffer.create_mark('mark_click', click_iter, false)
          populate_menu(menu, mark_click)
          menu.popup(nil, nil, event.button, event.time)
        end
      end

      signal_connect('destroy-event') do |me|
        menu.destroy

      end

      #signal_connect('populate-popup') do |me, menu|
      #  @spell_check = Aspell.new(DEFAULT_LANG)
      #  curr_iter = me.buffer.get_iter_at_offset(me.buffer.cursor_position)
      #  curr_iter.tags.each do |tag|
      #    if tag.name == 'spell_error'
      #      curr_iter.forward_word_end
      #      end_iter = curr_iter.clone
      #      curr_iter.backward_word_start
      #      old_word = buffer.get_text(curr_iter, end_iter)
      #      puts "[#{word=curr_iter.get_text(end_iter)}]"
      #      @spell_check.suggest(word)[0...5].each do |word|
      #        puts "suggested word change is: #{word}"
      #        menu.append(sub=Gtk::MenuItem.new("#{word}"))
      #        sub.signal_connect('activate') do |widget|
      #          new_word = widget.label
      #          buffer.begin_user_action do 
      #            buffer.delete(curr_iter, end_iter)
      #            buffer.insert(curr_iter, new_word)
      #          end
      #        end
      #      end
      #    end
      #  end

      #  menu.show_all
      #end

    end

    def populate_menu(menu, mark_click)
      iters = get_word_iters(mark_click)
      get_suggestions_menu(menu, iters)
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
            buffer.begin_user_action do 
              buffer.delete(iters[0], iters[1])
              buffer.insert(iters[0], new_word)
            end
          end
        end
      end
      menu.show_all
    end

  end

end
end
