module GtkApp
module Dialog

  autoload(:Error,    'gtk_app/dialog/error')
  autoload(:Info,     'gtk_app/dialog/info')
  # autoload(:Wait,     'gtk_app/dialog/wait')
  autoload(:Warn,     'gtk_app/dialog/warn')
  autoload(:Ask,      'gtk_app/dialog/ask')
  autoload(:Notify,   'gtk_app/dialog/notify')
  # autoload(:Progress, 'gtk_app/dialog/progress')
   
  module Support

    module ClassMethods

      def show(parent, text, secondary_text=nil)
        dialog = new(parent)
        dialog.text  = text
        dialog.secondary_text = secondary_text if secondary_text

        result = Gtk::Dialog::RESPONSE_NONE
        dialog.run do |response|
          result = response
        end
        dialog.destroy
        
        result
      end

    end

    def self.included(base)
      base.extend(ClassMethods)
    end

  end

end
end