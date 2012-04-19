module GtkApp
class View < Gtk::Builder
  include GtkApp::Helpers
  include GtkApp::ViewHelpers

  # @param [GtkApp::Controller] controller
  # @param [String] builder_file Path the Gtk builder file
  def initialize(controller, builder_file, *args)
    super()
    # options = args.extract_options!
    self.add_from_file(builder_file)
    self.connect_signals { |handler| controller.method(handler) }

    self.objects.each do |widget|
      p widget.class
      mixin = case widget
      when Gtk::TextView then GtkApp::TextEditSupport 
      else nil
      end
      widget.class.send(:include, mixin) unless mixin.nil?
      puts widget.buffer if widget.is_a? Gtk::TextView
    end

    # self.title = options[:title] if options.key?(:title)
  end

  def method_missing(id, *args, &block)
    method_name = id.to_s

    widget_name = (method_name =~ /([!=]|<{2})$/ ? method_name.chop : method_name)
    widget = self["#{widget_name}"]
    super unless widget

    bang_proc, equal_proc, append_proc = case widget
    when Gtk::TextView then
      [ lambda { widget.buffer.text },
        lambda { |*argv| widget.buffer.text = argv[0].to_s },
        lambda { |text| widget.buffer.text << text.to_s } ]
    when Gtk::ComboBox then
      [ lambda { widget.active_text },
        lambda do |*argv|
          if argv[0].is_a?(Fixnum)
            widget.active = argv[0]
          elsif widget.model
            result = nil
            widget.model.each do |m, p, i|
              result = iter if iter[0] =~ /\A#{argv[0]}/i
            end
            widget.active_iter = result if result
          end
        end,
        lambda { |text| widget.append_text(text.to_s) } ]
    when Gtk::ToggleButton, Gtk::CheckButton then
      [ lambda { widget.active? },
        lambda { |*argv| widget.active = argv[0] },
        nil ]
    when Gtk::TreeView then
      [ lambda { widget.selection.selected },
        nil,
        lambda do |row|
          iter = widget.model.append
          if row.is_a?(Gtk::TreeIter)
            (0..model.n_columns).each { |i| iter[i] = row[i] }
          else
            row.each_with_index { |v,i| iter[i] = v }
          end
          iter
        end ]
    else
      if widget.respond_to?(:text)
        [ lambda { widget.text },
          lambda { |*argv| widget.text = argv[0].to_s },
          lambda { |text| widget.text = ("#{widget.text}" << text) } ]
      else [nil, nil, nil]; end
    end

    class_eval do
      define_method(:"#{widget_name}", lambda { widget })
      define_method(:"#{widget_name}!", bang_proc) if bang_proc
      define_method(:"#{widget_name}=", equal_proc) if equal_proc
    end

    widget.class_eval do
      define_method("<<", append_proc)
    end if append_proc

    send(:"#{method_name}", *args, &block)
  end
  
  # TODO: def restore_geometry
  # end
  
end
end
