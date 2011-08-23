module GtkApp
module ViewHelpers
  
  def build_listview(widget_name, columns, options={}, &block) # :yields: index, header, column, renderer
    list = self.send(:"#{widget_name}")
    list.model = Gtk::ListStore.new(*columns.values)
    columns.each_with_index do |keyval, index|
      header, data_type = keyval
      renderer, attrs = case data_type
      when String, Integer
        [Gtk::CellRendererText.new, :text => index]
      when TrueClass
        toggle = Gtk::CellRendererToggle.new
        toggle.signal_connect('toggled') do |widget, path|
          iter = list.model.get_iter(path)
          iter[index] = !iter[index]
        end
        [toggle, :active => index]
      when Gtk::ListStore
        _renderer = Gtk::CellRendererCombo.new
        model = Gtk::ListStore.new(String)
        _renderer.signal_connect("edited") do |cell, path, text|
          model.get_iter(path)[index] = text
        end
        [_renderer, :text_column => 0, :model => model, :text => index, 
          :editable => index]
      else
        raise("GtkApp::View##{__method__} does not know how to handle " + 
          "'#{data_type}' data types.")
      end

      column = Gtk::TreeViewColumn.new("#{header}".titleize, renderer, attrs)
      column.visible = false if index == 0
      yield(index, header, column, renderer) if block_given?

      if options.key?(:formatter) && options[:formatter].is_a?(Proc)
        column.set_cell_data_func(renderer, &options[:formatter])
      end

      list.append_column(column)
    end
  end
  
  # Set *widgets sensitive property to true
  #== Example
  # @view.sensitize(:txtFoo, :cmbBar)
  def sensitize(*widgets)
    widgets.each { |w| self["#{w}"].sensitive = true }
  end
  
  # Set *widgets sensitive property to false
  #== Example
  # @view.desensitize(:txtFoo, :cmbBar)
  def desensitize(*widgets)
    widgets.each { |w| self["#{w}"].sensitive = false }
  end
  
end
end