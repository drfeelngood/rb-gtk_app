require File.dirname(__FILE__) + '/test_helper'

module TestApplication
class Model < GtkApp::Model
  validates :txtUpcase, :format => { :with => /[A-Z]/ }
end
class Controller < GtkApp::Controller


  %w[Info Error Warn Ask Wait].each do |dialog|
    on :"btn#{dialog}", 'clicked' do |widget|
      eval("GtkApp::Dialog::#{dialog}").show(@view.main_window, "This is a test", 
        "foo bar"*20 )
    end
  end
  
  on :btnNotify, 'clicked' do |clicked|
    GtkApp::Dialog::Notify.new("GtkApp::Dialog::Notify", "Hello World")
  end
  
  on :btnProgress, 'clicked' do |clicked|
    @model.validations.each do |v|
      p v
    end
    # max = 100
    # dialog = GtkApp::Dialog::Progress.new
    # (0..max).each do |x|
    #   
    # end
  end

  on :btnYes, 'clicked' do |widget|
    quit(false)
  end

  on :btnNo, 'clicked' do |widget|
    quit(false)
  end

  on :btnBold, 'clicked' do |widget|
    @view.txtView.buffer.format_selection(:bold)
  end
  
  %w[Bold Italic Underline Strikethrough].each do |name|
    on :"btn#{name}", 'clicked' do |widget|
      @view.txtView.buffer.format_selection(name.downcase.to_sym)
    end
  end
  
  on :btnClear, 'clicked' do |widget|
    @view.txtView.buffer.clear_selection
  end

end
end

#
# Main
#
begin
  TestApplication::Controller.new do
    @view  = GtkApp::View.new(self, "#{File.expand_path('../', __FILE__)}/test.ui")
    @model = TestApplication::Model.new
    # formatter = lambda do |col, renderer, model, iter|
    #   unless renderer.is_a?(Gtk::CellRendererToggle)
    #     renderer.foreground = (iter[2] ? 'blue' : 'red')
    #   end
    # end

    # @view.build_listview(:listviewTest, 
    #     { :id => Integer, :todo => String, :complete? => TrueClass }, 
    #     :formatter => formatter) do |index, header, column, renderer|
    #   
    #   column.expand = true if index == 1
    # end
    # 
    # (1..5).each_with_index do |v, i|
    #   @view.listviewTest << [i, "Todo ##{i}", false]
    # end
    
    fancy_buffer = GtkApp::TextBuffer.new
    fancy_buffer.text = File.read(File.dirname(__FILE__) + '/test.txt')
    @view.txtView.buffer = fancy_buffer
    
  end
  
  GtkApp.run
rescue Object => boom
  puts "#{boom.message}\n#{boom.backtrace.join("\n")}"
  exit(1)
end