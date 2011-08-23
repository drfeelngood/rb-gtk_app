require 'raspell'

module GtkApp
class TextBuffer < Gtk::TextBuffer
  attr_reader :speller

  DEFAULT_LANG = "en_US"
  DEFAULT_TAGS = %w[bold italic strikethrough underline error spell_error]
  
  def initialize(tag_table=nil, options={})
    super(tag_table)
    @stack = []
    @speller = Aspell.new(options[:lang] || DEFAULT_LANG)
    setup_default_tags
    # TODO: setup_signals
  end
  
  def undo
    # TODO: Undo stack support
  end
  
  def redo
    # TODO: Redo stack support
  end

  def word_at_cursor
    puts "[#{get_text(*word_bounds).strip}]"
  end
  
  def word_bounds
    iter = get_iter_at_offset(cursor_position)
    # unless iter.start?
    s_iter, e_iter = iter.clone, iter.clone
    s_iter.backward_word_start
    e_iter.forward_word_end

    [s_iter, e_iter]
  end

  def check_spelling(word=nil, s_iter=nil, e_iter=nil)
    if word.nil?
      text.gsub(/[\w\']+/) do |word| check_spelling(word); end
    elsif !@speller.check(word)
      s, e = start_iter.forward_search(word, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
      format(:spell_error, s, e)
    end
  end
  
  #
  # Locate text in selection or the entire buffer.  If found, a Gtk::TextMark
  # is returned.  Else, nil.
  def search(word)
    s_iter, e_iter, text_selected = selection_bounds
    s_iter = start_iter unless text_selected
    s_iter, e_iter = s_iter.forward_search(work, Gtk::TextIter::SEARCH_TEXT_ONLY, e_iter)
    s_iter ? create_mark(nil, s_iter, false) : nil
  end
  
  #
  # Format text in the current selection range with a Gtk::TextTag identified by
  # the given name.
  def format_selection(tag_name)
    s, e, text_selected = selection_bounds
    format(tag_name, s, e) if text_selected
  end
  
  def format(tag_name, s_iter, e_iter)
    apply_tag(tag_name.to_s, s_iter, e_iter)
  end
  
  #
  # Remove all occurrences of a Gtk::TextTag in the given selection range.
  def clear_selection(*tag_names)
    s, e, text_selected = selection_bounds
    if text_selected
      if tag_names.empty?
        clear_all(s, e)
      else
        tag_names.each { |tag_name| clear(tag_name, s, e) }
      end
    end
  end
  
  def clear(tag_name, s_iter, e_iter)
    remove_tag(tag_name.to_s, s_iter, e_iter)
  end
  
  def clear_all(s_iter, e_iter)
    remove_all_tags(s_iter, e_iter)
  end

  private

    #
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
    
    def setup_signals
      signal_connect('begin-user-action') do |me|
        # TODO:
      end
      
      signal_connect('end-user-action') do |me|
        # TODO:
      end
    end

end
end