require 'ffi/aspell'

module GtkApp
class TextBuffer < Gtk::TextBuffer
 
  # !@attribute [r] spell_check
  # Aspell object
  # @return [FFI::Aspell::Speller]
  attr_reader :spell_check

  # !@attribute [r] undo_stack
  # Collection of actions performed
  # @return [Array]
  attr_reader :undo_stack 
    
  # !@attribute [r] redo_stack
  # Collection of actions undone
  # @return [Array]
  attr_reader :redo_stack
  
  # !@attribute [r] text_marks
  # Collection of named text marks used to track user input
  # @return [Hash]
  attr_reader :text_marks

  DEFAULT_LANG = "en_US"
  DEFAULT_TAGS = %w[bold italic strikethrough underline error spell_error]
  DEFAULT_ENCODING = 'UTF-8'

  def initialize(tag_table=nil, options={})
    super(tag_table)
    @undo_stack, @redo_stack = [], []
    
    options[:lang] ||= DEFAULT_LANG
    options[:encoding] ||= DEFAULT_ENCODING
    @spell_check = FFI::Aspell::Speller.new(options[:lang], options)
    
    setup_default_tags
    setup_text_marks
    setup_signals
  end

  # @param [Gtk::TextView]
  def view=(text_view)
    text_view.instance_eval do
      signal_connect('button-press-event', &:__button_press_event)
      signal_connect('populate-popup', &:__populate_popup)
    end
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

  # Helper method to check the spelling of every word in the buffer.
  def check_spelling
    check_range(*bounds)
  end

  # @param [Gtk::TextIter] s_iter
  # @param [Gtk::TextIter] e_iter
  def check_range(s_iter, e_iter)
    e_iter.forward_word_end if e_iter.inside_word?
    unless s_iter.starts_word?
      if s_iter.inside_word? || s_iter.ends_word?
        s_iter.backward_word_start
      elsif s_iter.forward_word_end
        s_iter.backward_word_start
      end
    end
    # Get the iter at the current cursor position and the pre cursor.
    c_iter  = get_iter_at_offset(cursor_position)
    pc_iter = c_iter.clone
    pc_iter.backward_char
    
    spell_error = tag_table.lookup('spell_error')
    has_error = (c_iter.has_tag?(spell_error) || pc_iter.has_tag?(spell_error))
    clear(:spell_error, s_iter, e_iter)
    
    # NOTE: From GtkSpell, catch rare cases when the replacement occurs at the
    # beginning of the buffer.  An iter at offset 0 seems to always be inside a
    # word even if it's not.
    if get_iter_at_offset(0) == s_iter
      s_iter.forward_word_end
      s_iter.backward_word_start
    end
    
    ws_iter = s_iter.clone # => Word start iter
    while (ws_iter <=> e_iter) < 0 do
      we_iter = ws_iter.clone  # => Word end iter
      we_iter.forward_word_end
      
      if ((ws_iter <=> c_iter) < 0) && ((c_iter <=> we_iter) <= 0)
        # The current word is being actively edited.  Only check it if it's
        # already been identified as incorrect.  Else, check later.
        check_word(ws_iter, we_iter) if has_error  
      else
        check_word(ws_iter, we_iter)
      end
      # Move the word end iter the the beginning of the next word.
      we_iter.forward_word_end
      we_iter.backward_word_start
      break if we_iter == ws_iter

      ws_iter = we_iter.clone
    end
  end

  # @param [Gtk::TextIter] s_iter
  # @param [Gtk::TextIter] e_iter
  def check_word(s_iter, e_iter)
    word = get_text(s_iter, e_iter)
    unless @spell_check.correct?(word)
      format(:spell_error, s_iter, e_iter)
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

    def setup_text_marks
      @text_marks = { 
        insert_start: create_mark('insert_start', start_iter, true),
        insert_end: create_mark('insert_end', start_iter, true),
        click: create_mark('click', start_iter, true)
      }
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
        move_mark(me.text_marks[:insert_start], iter) 
      end

      signal_connect_after('insert-text') do |me, iter, text, len|
        s_iter = get_iter_at_mark(me.text_marks[:insert_start])
        check_range(s_iter, iter)
        move_mark(me.text_marks[:insert_end], iter)
      end
      
      signal_connect('delete-range') do |me, s_iter, e_iter|
        if user_action?
          text = get_text(s_iter, e_iter)
          @undo_stack << [:delete, s_iter.offset, e_iter.offset, text]
        end
      end

      signal_connect_after('delete-range') do |me, s_iter, e_iter|
        check_range(s_iter, e_iter)
      end
    end
    
    def user_action?
      @user_action
    end
    
end
end
