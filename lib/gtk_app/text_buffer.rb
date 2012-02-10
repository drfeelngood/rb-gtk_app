require 'raspell'

module GtkApp
class TextBuffer < Gtk::TextBuffer
  attr_reader :spell_check
  attr_reader :undo_stack, :redo_stack

  DEFAULT_LANG = "en_US"
  DEFAULT_TAGS = %w[bold italic strikethrough underline error spell_error]

  def initialize(tag_table=nil, options={})
    super(tag_table)
    @undo_stack, @redo_stack = [], []
    @spell_check = Aspell.new(options[:lang] || DEFAULT_LANG)
    setup_default_tags
    setup_signals
  end

  # Pop the last action off the undo stack and rewind changes. If an action was
  # performed, the cursor is placed at the actions starting 
  # Gtk::TextIter[http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ATextIter].
  def undo
    if @undo_stack.empty?
      Gdk.beep
    else
      action = @undo_stack.pop
      s_iter = get_iter_at_offset(action[1])
      case action[0]
      when :insert then delete(s_iter, get_iter_at_offset(action[2]))
      when :delete then insert(s_iter, action[3])
      end
      @redo_stack.push(action)
      place_cursor(s_iter)
    end
  end

  # Pop the last action off the redo stack and apply the changes.  If and action
  # was performed, the cursor is placed at the actions starting 
  # Gtk::TextIter[http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ATextIter].
  def redo
    if @redo_stack.empty?
      Gdk.beep
    else
      action = @redo_stack.pop
      s_iter = get_iter_at_offset(action[1])
      e_iter = get_iter_at_offset(action[2])
      case action[0]
      when :insert then insert(s_iter, action[3])
      when :delete then delete(s_iter, e_iter)
      end
      @undo_stack.push(action)
      place_cursor(s_iter)
    end
  end

  # Retrieve the word at the current cursor position
  # @return [String] The word.
  def word_at_cursor
    get_text(*word_bounds).strip
  end

  # Determine the boudaries of the word at the current cursor position.
  # @return [Array] The start and end iter.
  def word_bounds
    iter = get_iter_at_offset(cursor_position)
    s_iter, e_iter = iter.clone, iter.clone
    s_iter.backward_word_start unless s_iter.starts_word?
    e_iter.forward_word_end unless e_iter.ends_word?

    [s_iter, e_iter]
  end

  def check_spelling(word=nil, s_iter=nil, e_iter=nil)
    if word.nil?
      text.gsub(/[\w\']+/) do |w| check_spelling(w); end
    elsif !@spell_check.check(word)
      s, e = start_iter.forward_search(word, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
      format(:spell_error, s, e)
    end
  end

  # Does the 
  # Gtk::TextTagTable[http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ATextTagTable] 
  # contain any 'spell_error' tags?
  def spelling_errors?
    !tag_table.lookup('spell_error').nil?
  end

  # Locate text in selection or the entire buffer.  If found, a 
  # Gtk::TextMark[http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ATextMark]
  # is returned.  Else, nil.
  # @param [String] string Text to search.
  def find(string)
    s_iter, e_iter, text_selected = selection_bounds
    s_iter = start_iter unless text_selected
    s_iter, e_iter = s_iter.forward_search(string, Gtk::TextIter::SEARCH_TEXT_ONLY, e_iter)
    s_iter ? create_mark(nil, s_iter, false) : nil
  end

  # @param [String] string Text to replace the selection with.
  # @param [Gtk::TextIter] s_iter
  # @param [Gtk::TextIter] e_iter
  def replace(string, s_iter, e_iter)
    begin_user_action
    delete(s_iter, e_iter)
    insert(s_iter, string)
    end_user_action
    place_cursor(s_iter)
  end

  # Format text in the current selection range with a 
  # Gtk::TextTag[http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ATextTag] 
  # identified by the given name.
  # @param [String] tag_name
  def format_selection(tag_name)
    s_iter, e_iter, text_selected = selection_bounds
    format(tag_name, s_iter, e_iter) if text_selected
  end
  
  # This is a small wrapper around the 
  # Gtk::TextBuffer#apply_tag[http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ATextBuffer#apply_tag] 
  # method.  It  allows the Gtk::TextTag name to be passed as a symbol.
  # @param [] tag_name
  # @param [Gtk::TextIter] s_iter
  # @param [Gtk::TextIter] e_iter
  def format(tag_name, s_iter, e_iter)
    apply_tag(tag_name.to_s, s_iter, e_iter)
  end
  
  # Remove all occurrences of a 
  # Gtk::TextTag[http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ATextTag] 
  # in the given selection range.
  def clear_selection(*tag_names)
    s_iter, e_iter, text_selected = selection_bounds
    if text_selected
      if tag_names.empty?
        clear_all(s_iter, e_iter)
      else
        tag_names.each { |tag_name| clear(tag_name, s_iter, e_iter) }
      end
    end
  end

  # Remove all tags of a given name from from one
  # Gtk::TextIter[http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ATextIter] 
  # to another.
  # @param [] tag_name
  # @param [Gtk::TextIter] s_iter
  # @param [Gtk::TextIter] e_iter
  def clear(tag_name, s_iter, e_iter)
    remove_tag(tag_name.to_s, s_iter, e_iter)
  end

  # Remove all Gtk::TextTag's from one 
  # Gtk::TextIter[http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ATextIter] 
  # to another.
  # @param [Gtk::TextIter] s_iter
  # @param [Gtk::TextIter] e_iter
  def clear_all(s_iter, e_iter)
    remove_all_tags(s_iter, e_iter)
  end

  private

    # Establish default tag names for everyday text formatting.
    def setup_default_tags
      DEFAULT_TAGS.each do |name|
        attibs = case name
        when 'bold'          then { weight: Pango::WEIGHT_BOLD }
        when 'italic'        then { style: Pango::STYLE_ITALIC }
        when 'strikethrough' then { strikethrough: true }
        when 'underline'     then { underline: Pango::UNDERLINE_SINGLE }
        when 'error'         then { underline: Pango::UNDERLINE_ERROR }
        when 'spell_error'   then { underline: Pango::UNDERLINE_ERROR }
        end
        create_tag(name, attibs)
      end
    end

    # Establish base signal handlers.  Here we track user actions and...
    def setup_signals
      signal_connect('begin-user-action') { |me| @user_action = true  }
      signal_connect('end-user-action')   { |me| @user_action = false }
      
      signal_connect('insert-text') do |me, iter, text, len|
        if user_action?
          @undo_stack << [:insert, iter.offset, 
            (iter.offset + text.scan(/./).size), text]
          @redo_stack.clear
        end
      end
      
      signal_connect('delete-range') do |me, s_iter, e_iter|
        if user_action?
          text = get_text(s_iter, e_iter)
          @undo_stack << [:delete, s_iter.offset, e_iter.offset, text]
        end
      end

      # TODO: Add suggestion popups for spelling erros.
      # tag_table.lookup('spell_error').signal_connect('event') do |tag|
      # end
    end
    
    def user_action?
      @user_action
    end

end
end